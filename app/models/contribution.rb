class Contribution < ActiveRecord::Base
  include Shared::StateMachineHelpers,
          Shared::PaymentStateMachineHandler,
          Contribution::CustomValidators,
          Shared::Notifiable,
          Shared::Payable

  belongs_to :user
  belongs_to :project
  belongs_to :reward
  has_many :matchings
  belongs_to :matching

  validates_presence_of :project, :user, :value
  validates_numericality_of :value, greater_than_or_equal_to: 10.00

  scope :available_to_count, ->{ with_states(['confirmed', 'requested_refund', 'refunded']) }
  scope :available_to_display, ->{ with_states(['confirmed', 'requested_refund', 'refunded']) }
  scope :by_id, ->(id) { where(id: id) }
  scope :by_key, ->(key) { where(key: key) }
  scope :by_user_id, ->(user_id) { where(user_id: user_id) }
  scope :user_name_contains, ->(term) { joins(:user).where("unaccent(upper(users.name)) LIKE ('%'||unaccent(upper(?))||'%')", term) }
  scope :user_email_contains, ->(term) { joins(:user).where("unaccent(upper(users.email)) LIKE ('%'||unaccent(upper(?))||'%')", term) }
  scope :payer_email_contains, ->(term) { where("unaccent(upper(payer_email)) LIKE ('%'||unaccent(upper(?))||'%')", term) }
  scope :project_name_contains, ->(term) { joins(:project).where("unaccent(upper(projects.name)) LIKE ('%'||unaccent(upper(?))||'%')", term) }
  scope :anonymous, -> { where(anonymous: true) }
  scope :credits, -> { where(credits: true) }
  scope :not_anonymous, -> { where(anonymous: false) }
  scope :confirmed_today, -> { with_state('confirmed').where("contributions.confirmed_at::date = current_timestamp::date ") }

  scope :can_cancel, -> { where("contributions.can_cancel") }

  # Contributions already refunded or with requested_refund should appear so that the user can see their status on the refunds list
  scope :can_refund, ->{ where("contributions.can_refund") }

  def self.between_values(start_at, ends_at)
    return all unless start_at.present? && ends_at.present?
    where("value between ? and ?", start_at, ends_at)
  end

  def matched_contributions
    self.class.where(matching_id: matchings)
  end

  def matches
    matched_contributions
  end

  def as_json(options = {})
    return super unless options.empty?

    PayableResourceSerializer.new(self).to_json
  end

  def recommended_projects
    user.recommended_projects.where("projects.id <> ?", project.id).order("count DESC")
  end

  def refund_deadline
    created_at + 180.days
  end

  def change_reward! reward
    self.reward_id = reward
    self.save
  end

  def can_refund?
    confirmed? && project.failed?
  end

  def available_rewards
    Reward.where(project_id: self.project_id).where('minimum_value <= ?', self.value).order(:minimum_value)
  end
end
