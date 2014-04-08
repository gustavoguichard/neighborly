class Channel < ActiveRecord::Base
  extend CatarseAutoHtml
  include Shared::StateMachineHelpers
  include Channel::StateMachineHandler
  include Channel::StartContent
  include Channel::SuccessContent

  has_many :subscriber_reports
  has_many :channels_subscribers
  belongs_to :user
  has_and_belongs_to_many :projects
  has_and_belongs_to_many :subscribers
  has_many :channel_members
  has_and_belongs_to_many :projects, -> { order("online_date desc") }
  has_and_belongs_to_many :subscribers, class_name: 'User', join_table: :channels_subscribers
  has_many :subscriber_reports
  has_many :channel_members, dependent: :destroy
  has_many :members, through: :channel_members, source: :user
  belongs_to :user, autosave: true

  accepts_nested_attributes_for :user

  validates_presence_of :name, :description, :permalink, :user
  validates_uniqueness_of :permalink
  after_validation :update_video_embed_url

  catarse_auto_html_for field: :how_it_works, video_width: 560, video_height: 340
  catarse_auto_html_for field: :submit_your_project_text

  delegate :display_video_embed_url, to: :decorator
  mount_uploader :image, ChannelUploader, mount_on: :image

  scope :by_permalink, ->(p) { where("lower(channels.permalink) = lower(?)", p) }

  def self.find_by_permalink!(string)
    self.by_permalink(string).first!
  end

  def has_subscriber? user
    user && subscribers.where(id: user.id).first.present?
  end

  def to_s
    self.name
  end

  def video
    @video ||= VideoInfo.get(self.video_url) if self.video_url.present?
  end

  def update_video_embed_url
    self.video_embed_url = self.video.embed_url if self.video_url.present?
  end

  # Links to channels should be their permalink
  def to_param; self.permalink end

  # Using decorators
  def decorator
    @decorator ||= ChannelDecorator.new(self)
  end

  def user_attributes=(user_attributes)
    if self.user.present?
      unless self.persisted?
        user_attributes.delete(:email)
        user_attributes.delete(:password)
      end
      self.user.update_attributes(user_attributes.merge({ profile_type: 'channel' }))
    else
      self.user = User.new(user_attributes.merge({ profile_type: 'channel' }))
    end
  end
end
