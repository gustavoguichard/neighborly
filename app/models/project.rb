# coding: utf-8
class Project < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  include PgSearch
  include Taggable
  extend CatarseAutoHtml
  include Shared::StateMachineHelpers
  include Project::StateMachineHandler
  include Project::VideoHandler
  include Project::CustomValidators
  include Project::OrganizationType

  mount_uploader :uploaded_image, ProjectUploader, mount_on: :uploaded_image
  mount_uploader :hero_image, HeroImageUploader, mount_on: :hero_image
  has_permalink :name, true
  geocoded_by :address
  after_validation :geocode # auto-fetch coordinates

  delegate :display_status, :display_progress, :display_image, :display_expires_at, :remaining_text, :time_to_go,
    :display_pledged, :display_goal, :remaining_days, :progress_bar, :successful_flag, :display_address_formated,
    :display_organization_type,
    to: :decorator

  belongs_to :user
  belongs_to :category
  has_many :contributions, dependent: :destroy
  has_many :rewards, dependent: :destroy
  has_many :updates, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :project_faqs, dependent: :destroy
  has_many :project_documents, dependent: :destroy
  has_and_belongs_to_many :channels
  has_many :unsubscribes
  has_one :project_total

  accepts_nested_attributes_for :rewards
  accepts_nested_attributes_for :project_documents

  catarse_auto_html_for field: :about, video_width: 720, video_height: 405
  catarse_auto_html_for field: :budget, video_width: 720, video_height: 405
  catarse_auto_html_for field: :terms, video_width: 720, video_height: 405

  pg_search_scope :pg_search, against: [
      [:name, 'A'],
      [:headline, 'B'],
      [:about, 'C']
    ],
    associated_against:  {user: [:name, :address_city ]},
    using: {tsearch: {dictionary: "english"}},
    ignoring: :accents

  # Used to simplify a has_scope
  scope :successful, ->{ with_state('successful') }
  scope :with_project_totals, -> { joins('LEFT OUTER JOIN project_totals pt ON pt.project_id = projects.id') }
  scope :by_progress, ->(progress) { joins(:project_total).where("project_totals.pledged >= projects.goal*?", progress.to_i/100.to_f) }
  scope :by_user_email, ->(email) { joins('JOIN users as u ON u.id = projects.user_id').where("u.email = ?", email) }
  scope :by_id, ->(id) { where(id: id) }
  scope :find_by_permalink!, ->(p) { without_state('deleted').where("lower(permalink) = lower(?)", p).first! }
  scope :by_category_id, ->(id) { where(category_id: id) }
  scope :name_contains, ->(term) { where("unaccent(upper(name)) LIKE ('%'||unaccent(upper(?))||'%')", term) }
  scope :user_name_contains, ->(term) { joins(:user).where("unaccent(upper(users.name)) LIKE ('%'||unaccent(upper(?))||'%')", term) }
  scope :featured, -> { not_soon.visible.where(featured: true).limit(1) }
  scope :by_goal, ->(goal) { where(goal: goal) }
  scope :by_online_date, ->(online_date) { where("online_date::date = ?", online_date.to_date) }
  scope :by_expires_at, ->(expires_at) { where("projects.expires_at::date = ?", expires_at.to_date) }
  scope :by_updated_at, ->(updated_at) { where("updated_at::date = ?", updated_at.to_date) }
  scope :by_permalink, ->(p) { without_state('deleted').where("lower(permalink) = lower(?)", p) }
  scope :to_finish, ->{ expired.with_states(['online', 'waiting_funds']) }
  scope :visible, -> { without_states(['draft', 'rejected', 'deleted']) }
  scope :financial, -> { with_states(['online', 'successful', 'waiting_funds']).where("projects.expires_at > (current_timestamp - '15 days'::interval)") }
  scope :recommended, -> { where(recommended: true) }
  scope :home_page, -> { where(home_page: true) }
  scope :expired, -> { where("projects.expires_at < current_timestamp") }
  scope :not_expired, -> { where("projects.expires_at >= current_timestamp") }
  scope :expiring, -> { not_expired.where("projects.expires_at <= (current_timestamp + interval '2 weeks')") }
  scope :not_expiring, -> { not_expired.where("NOT (projects.expires_at <= (current_timestamp + interval '2 weeks'))") }
  scope :recent, -> { where("(current_timestamp - projects.online_date) <= '5 days'::interval") }
  scope :soon, -> { with_state('soon') }
  scope :not_soon, -> { where("projects.state NOT IN ('soon')") }
  scope :order_for_search, ->{ reorder("
                                     CASE projects.state
                                     WHEN 'online' THEN 1
                                     WHEN 'waiting_funds' THEN 2
                                     WHEN 'successful' THEN 3
                                     WHEN 'failed' THEN 4
                                     END ASC, projects.online_date DESC, projects.created_at DESC") }

  scope :contributed_by, ->(user_id){
    where("id IN (SELECT project_id FROM contributions b WHERE b.state = 'confirmed' AND b.user_id = ?)", user_id)
  }

  scope :from_channels, ->(channels){
    where("EXISTS (SELECT true FROM channels_projects cp WHERE cp.project_id = projects.id AND cp.channel_id = ?)", channels)
  }

  scope :with_contributions_confirmed_today, -> {
    joins(:contributions).merge(Contribution.confirmed_today).uniq
  }

  validates :video_url, :online_days, :address_city, :address_state, presence: true, if: ->(p) { p.state_name == 'online' }
  validates_presence_of :name, :user, :category, :about, :headline, :goal, :permalink, :address
  validates_length_of :headline, maximum: 140
  validates_numericality_of :online_days
  validates_uniqueness_of :permalink, allow_blank: true, case_sensitive: false, on: :update
  validates_format_of :permalink, with: /\A(\w|-)*\z/, allow_blank: true
  validates_format_of :video_url, with: /(https?\:\/\/|)(youtu(\.be|be\.com)|vimeo).*+/, message: I18n.t('project.video_regex_validation'), allow_blank: true

  before_validation do
    if self.site.present?
      self.site = "http://#{self.site}" if not self.site[0..6] == 'http://' and not self.site[0..7] == 'https://'
    end
  end

  def address=(address)
    array = address.split(',')
    self.address_city = array[0].lstrip.titleize if array[0]
    self.address_state = array[1].lstrip.upcase if array[1]

    if not address.present?
      self.address_city = self.address_state = nil
    end
  end

  def address
    [address_city, address_state].select { |a| a.present? }.compact.join(', ')
  end

  def self.between_created_at(start_at, ends_at)
    return scoped unless start_at.present? && ends_at.present?
    where("created_at between to_date(?, 'dd/mm/yyyy') and to_date(?, 'dd/mm/yyyy')", start_at, ends_at)
  end

  def self.between_expires_at(start_at, ends_at)
    return scoped unless start_at.present? && ends_at.present?
    where("projects.expires_at between to_date(?, 'dd/mm/yyyy') and to_date(?, 'dd/mm/yyyy')", start_at, ends_at)
  end

  [:between_created_at, :between_expires_at, :between_online_date, :between_updated_at].each do |name|
    define_singleton_method name do |starts_at, ends_at|
      between_dates name.to_s.gsub('between_',''), starts_at, ends_at
    end
  end

  def self.goal_between(starts_at, ends_at)
    where("goal BETWEEN ? AND ?", starts_at, ends_at)
  end

  def self.order_by(sort_field)
    return scoped unless sort_field =~ /^\w+(\.\w+)?\s(desc|asc)$/i
    order(sort_field)
  end

  def self.campaign_type_names
    ["flexible", "all_or_none"]
  end

  def subscribed_users
    User.subscribed_to_updates.subscribed_to_project(self.id)
  end

  def decorator
    @decorator ||= ProjectDecorator.new(self)
  end

  def expires_at
    online_date && (online_date + online_days.days).end_of_day
  end

  def pledged
    project_total ? project_total.pledged : 0.0
  end

  def total_contributions
    project_total ? project_total.total_contributions : 0
  end

  def total_payment_service_fee
    project_total ? project_total.total_payment_service_fee : 0.0
  end

  def selected_rewards
    rewards.sort_asc.where(id: contributions.with_state('confirmed').map(&:reward_id))
  end

  def reached_goal?
    pledged >= goal
  end

  def expired?
    expires_at && expires_at < Time.zone.now
  end

  def in_time_to_wait?
    contributions.with_state('waiting_confirmation').count > 0
  end

  def progress
    return 0 if goal == 0.0
    ((pledged / goal * 100).abs).round(pledged.to_i.size).to_i
  end

  def pending_contributions_reached_the_goal?
    pledged_and_waiting >= goal
  end

  def pledged_and_waiting
    contributions.with_states(['confirmed', 'waiting_confirmation']).sum(:value)
  end

  def new_draft_recipient
    email = last_channel.try(:user).try(:email) || ::Configuration[:email_projects]
    User.where(email: email).first
  end

  def last_channel
    @last_channel ||= channels.last
  end

  def notification_type type
    channels.first ? "#{type}_channel".to_sym : type
  end

  private
  def self.between_dates(attribute, starts_at, ends_at)
    return scoped unless starts_at.present? && ends_at.present?
    where("projects.#{attribute}::date between to_date(?, 'dd/mm/yyyy') and to_date(?, 'dd/mm/yyyy')", starts_at, ends_at)
  end

  def self.locations
    visible.select('DISTINCT address_city, address_state').order('address_city, address_state').map(&:address)
  end

  private
  def self.get_routes
    routes = Rails.application.routes.routes.map do |r|
      r.path.spec.to_s.split('/').second.to_s.gsub(/\(.*?\)/, '')
    end
    routes.compact.uniq
  end
end
