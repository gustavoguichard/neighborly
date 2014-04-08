# coding: utf-8
require 'state_machine'

class User < ActiveRecord::Base
  include User::Completeness
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :lockable, :timeoutable and :omniauthable
  # :validatable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :omniauthable, :confirmable

  begin
    sync_with_mailchimp subscribe_data: ->(user) { { EMAIL: user.email, NAME: user.display_name } },
                        list_id: Configuration[:mailchimp_list_id],
                        subscribe_when: ->(user) { (user.newsletter_changed? && user.newsletter) || (user.newsletter && user.new_record?) },
                        unsubscribe_when: ->(user) { user.newsletter_changed? && !user.newsletter },
                        unsubscribe_email: ->(user) { user.email }
  rescue Exception => e
    Rails.logger.info "-----> #{e.inspect}"
  end

  geocoded_by :address
  after_validation :geocode # auto-fetch coordinates

  delegate :display_name, :display_image, :short_name, :display_image_html,
    :medium_name, :display_credits, :display_total_of_contributions, :first_name, :last_name, :gravatar_url,
    to: :decorator

  attr_accessor :address

  mount_uploader :uploaded_image, UserUploader, mount_on: :uploaded_image

  validates_length_of :bio, maximum: 140
  validates_presence_of :email
  validates_uniqueness_of :email, :allow_blank => true, :if => :email_changed?, :message => I18n.t('activerecord.errors.models.user.attributes.email.taken')
  validates_format_of :email, :with => Devise.email_regexp, :allow_blank => true, :if => :email_changed?

  validates_presence_of :password, :if => :password_required?
  validates_confirmation_of :password, :if => :password_confirmation_required?
  validates_length_of :password, :within => Devise.password_length, :allow_blank => true

  has_many :contributions
  has_many :projects
  has_many :notifications
  has_many :updates
  has_many :unsubscribes
  has_many :authorizations
  has_many :oauth_providers, through: :authorizations
  has_many :channels_subscribers
  has_one :user_total
  has_and_belongs_to_many :subscriptions, join_table: :channels_subscribers, class_name: 'Channel'
  has_one :channel
  has_one :organization, dependent: :destroy
  has_many :channel_members, dependent: :destroy
  has_many :channels, through: :channel_members, source: :channel
  has_and_belongs_to_many :recommended_projects, join_table: :recommendations, class_name: 'Project'

  accepts_nested_attributes_for :channel
  accepts_nested_attributes_for :organization
  accepts_nested_attributes_for :unsubscribes, allow_destroy: true rescue puts "No association found for name 'unsubscribes'. Has it been defined yet?"

  scope :contributions, -> {
    where("id IN (
      SELECT DISTINCT user_id
      FROM contributions
      WHERE contributions.state <> ALL(ARRAY['pending'::character varying::text, 'canceled'::character varying::text]))")
  }

  scope :who_contributed_project, ->(project_id) {
    where("id IN (SELECT user_id FROM contributions WHERE contributions.state = 'confirmed' AND project_id = ?)", project_id)
  }

  scope :subscribed_to_updates, -> {
     where("id NOT IN (
       SELECT user_id
       FROM unsubscribes
       WHERE project_id IS NULL)")
   }

  scope :subscribed_to_project, ->(project_id) {
    who_contributed_project(project_id).
    where("id NOT IN (SELECT user_id FROM unsubscribes WHERE project_id = ?)", project_id)
  }

  scope :by_email, ->(email){ where('email ~* ?', email) }
  scope :by_payer_email, ->(email) {
    where('EXISTS(
      SELECT true
      FROM contributions
      JOIN payment_notifications ON contributions.id = payment_notifications.contribution_id
      WHERE contributions.user_id = users.id AND payment_notifications.extra_data ~* ?)', email)
  }
  scope :by_name, ->(name){ where('users.name ~* ?', name) }
  scope :by_id, ->(id){ where(id: id) }
  scope :by_key, ->(key){ where('EXISTS(SELECT true FROM contributions WHERE contributions.user_id = users.id AND contributions.key ~* ?)', key) }
  scope :has_credits, -> { joins(:user_total).where('user_totals.credits > 0') }
  scope :has_not_used_credits_last_month, -> { has_credits.
    where("NOT EXISTS (SELECT true FROM contributions b WHERE current_timestamp - b.created_at < '1 month'::interval AND b.credits AND b.state = 'confirmed' AND b.user_id = users.id)")
  }
  scope :order_by, ->(sort_field){ order(sort_field) }

  state_machine :profile_type, initial: :personal do
    state :personal, value: 'personal'
    state :organization, value: 'organization'
    state :channel, value: 'channel'
  end

  def self.send_credits_notification
    has_not_used_credits_last_month.find_each do |user|
      Notification.notify_once(
        :credits_warning,
        user,
        {user_id: user.id}
      )
    end
  end

  def self.contribution_totals
    connection.select_one(
      self.all.
      joins(:user_total).
      select('
        count(DISTINCT user_id) as users,
        count(*) as contributions,
        sum(user_totals.sum) as contributed,
        sum(user_totals.credits) as credits').
      to_sql
    ).reduce({}){|memo,el| memo.merge({ el[0].to_sym => BigDecimal.new(el[1] || '0') }) }
  end

  def address=(address)
    array = address.split(',')
    self.address_city = array[0].lstrip.titleize if array[0]
    self.address_state = array[1].lstrip.upcase if array[1]

    if not address.present?
      self.address_city = self.address_state = self.longitude = self.latitude = nil
    end
  end

  def address
    [address_city, address_state].select { |a| a.present? }.compact.join(', ')
  end

  def decorator
    @decorator ||= UserDecorator.new(self)
  end

  def credits
    user_total ? user_total.credits : 0.0
  end

  def total_contributed_projects
    user_total ? user_total.total_contributed_projects : 0
  end

  def facebook_id
    auth = authorizations.joins(:oauth_provider).where("oauth_providers.name = 'facebook'").first
    auth.uid if auth
  end

  def to_param
    return "#{self.id}" unless self.display_name
    "#{self.id}-#{self.display_name.parameterize}"
  end

  def self.create_from_hash(hash)
    create!(
      {
        name: hash['info']['name'],
        email: hash['info']['email'],
        nickname: hash["info"]["nickname"],
        bio: (hash["info"]["description"][0..139] rescue nil),
        locale: I18n.locale.to_s
      }
    )
  end

  def total_contributions
    contributions.with_state('confirmed').not_anonymous.count
  end

  def updates_subscription
    unsubscribes.updates_unsubscribe(nil)
  end

  def project_unsubscribes
    contributed_projects.map do |p|
      unsubscribes.updates_unsubscribe(p.id)
    end
  end

  def projects_led
    projects.visible.not_soon
  end

  def total_led
    projects_led.count
  end

  def contributed_projects
    Project.contributed_by(self.id)
  end

  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end

  def password_confirmation_required?
    !new_record?
  end

  def confirmation_required?
    !confirmed? and not (authorizations.first and authorizations.first.oauth_provider == OauthProvider.where(name: 'facebook').first)
  end

  def update_social_info(hash)
    self.update_attributes(social_info_from_hash(hash))
  end

  protected
  def social_info_from_hash(hash)
    info = {}
    info[:twitter_url] = "http://twitter.com/#{hash['info']['nickname']}" if hash['provider'] == 'twitter'
    info[:linkedin_url] = hash['info']['urls']['public_profile'] if hash['provider'] == 'linkedin'
    info[:facebook_url] = "http://facebook.com/#{hash['info']['nickname']}" if hash['provider'] == 'facebook'
    unless self.uploaded_image.present?
      info[:remote_uploaded_image_url] = hash['info']['image'] if hash['info']['image'].present? && hash['provider'] != 'facebook'
      info[:remote_uploaded_image_url] = "https://graph.facebook.com/#{hash['uid']}/picture?type=large" if hash['provider'] == 'facebook'
    end
    info
  end
end
