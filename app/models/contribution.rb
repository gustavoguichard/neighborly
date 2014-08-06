class Contribution < ActiveRecord::Base
  include Shared::StateMachineHelpers,
          Shared::PaymentStateMachineHandler,
          Contribution::CustomValidators,
          Shared::Notifiable,
          Shared::Payable,
          PgSearch

  belongs_to :user
  belongs_to :project
  belongs_to :reward
  belongs_to :matching
  has_many   :matchings
  has_one :match, through: :matching

  validates_presence_of     :project, :user, :value
  validates_numericality_of :value, greater_than_or_equal_to: 10.00

  scope :available_to_count,   -> { with_states(['confirmed', 'requested_refund', 'refunded']) }
  scope :available_to_display, -> { with_states(['confirmed', 'requested_refund', 'refunded']) }
  scope :anonymous,            -> { where(anonymous: true) }
  scope :credits,              -> { where(credits: true) }
  scope :not_anonymous,        -> { where(anonymous: false) }
  scope :confirmed_today,      -> { with_state('confirmed').where("contributions.confirmed_at::date = current_timestamp::date ") }
  scope :can_cancel,           -> { where("contributions.can_cancel") }
  # Contributions already refunded or with requested_refund should appear so that the user can see their status on the refunds list
  scope :can_refund,           ->{ where("contributions.can_refund") }

  pg_search_scope :pg_search, against: [
      [:key,            'A'],
      [:value,          'B'],
      [:payment_method, 'C'],
      [:payment_id,     'D']
    ],
    associated_against: {
      user:    %i(id name email),
      project: %i(name)
    },
    using: {
      tsearch: {
        dictionary: 'english'
      }
    },
    ignoring: :accents

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

  def available_rewards
    Reward.where(project_id: self.project_id).where('minimum_value <= ?', self.value).order(:minimum_value)
  end

  def net_value
    if payment_service_fee_paid_by_user?
      value
    else
      value - payment_service_fee
    end
  end

  def payment_service_fee
    if match
      match.payment_service_fee / match.value * value
    else
      read_attribute(:payment_service_fee)
    end
  end
end
