# coding: utf-8
require 'state_machine'

class User < ActiveRecord::Base
  include User::Completeness,
          Shared::LocationHandler,
          PgSearch
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :lockable, :timeoutable and :omniauthable
  # :validatable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :omniauthable, :confirmable

  delegate :display_name, :display_image, :short_name, :display_image_html,
    :medium_name, :display_total_of_contributions, :first_name, :last_name, :referral_url,
    to: :decorator

  mount_uploader :uploaded_image, UserUploader, mount_on: :uploaded_image

  validates_length_of :bio, maximum: 140
  validates_presence_of :email
  validates_uniqueness_of :email, :allow_blank => true, :if => :email_changed?, :message => I18n.t('activerecord.errors.models.user.attributes.email.taken')
  validates_format_of :email, :with => Devise.email_regexp, :allow_blank => true, :if => :email_changed?

  validates_presence_of :password, if: :password_required?
  validates_length_of :password, :within => Devise.password_length, :allow_blank => true

  belongs_to :referrer, class_name: 'User', foreign_key: 'referrer_id'
  has_many :contributions
  has_many :projects
  has_many :notifications
  has_many :authorizations
  has_many :oauth_providers, through: :authorizations
  has_one :organization, dependent: :destroy
  has_and_belongs_to_many :recommended_projects, join_table: :recommendations, class_name: 'Project'
  has_one :investment_prospect, dependent: :destroy
  has_one :brokerage_account, dependent: :destroy
  belongs_to :access_code

  accepts_nested_attributes_for :authorizations
  accepts_nested_attributes_for :organization
  accepts_nested_attributes_for :investment_prospect

  pg_search_scope :pg_search, against: [
      [:name,  'A'],
      [:email, 'B'],
      [:bio,   'C'],
      [:id,    'D']
    ],
    associated_against: {
      organization: %i(name)
    },
    using: {
      tsearch: {
        dictionary: 'english'
      }
    },
    ignoring: :accents

  scope :who_contributed_project, ->(project_id) {
    where("id IN (SELECT user_id FROM contributions WHERE contributions.state = 'confirmed' AND project_id = ?)", project_id)
  }

  state_machine :profile_type, initial: :personal do
    state :personal, value: 'personal'
    state :organization, value: 'organization'
  end

  def decorator
    @decorator ||= UserDecorator.new(self)
  end

  def total_contributed_projects
    contributions.count('distinct project_id')
  end

  def facebook_id
    auth = authorizations.joins(:oauth_provider).where("oauth_providers.name = 'facebook'").first
    auth.uid if auth
  end

  def to_param
    return "#{self.id}" unless self.name
    "#{self.id}-#{self.name.parameterize}"
  end

  def total_contributions
    contributions.with_state('confirmed').not_anonymous.count
  end

  def password_required?
    !bonds_early_adopter? && new_record?
  end

  def confirmation_required?
    !confirmed? and not (authorizations.first and authorizations.first.oauth_provider == OauthProvider.where(name: 'facebook').first)
  end

  def ahead_me
    User.where('created_at < ?', created_at).count
  end

  def behind_me
    User.where('created_at > ?', created_at).count
  end

  def turn_beta(new_access_code = nil)
    self.beta = true
    self.access_code = new_access_code if new_access_code
    save

    Notification.notify_once(
      :welcome_to_beta,
      self,
      { user_id: id }
    )
  end
end
