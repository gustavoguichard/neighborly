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

  validates_presence_of :project, :user, :value

  scope :available_to_count,   -> { with_states(['confirmed', 'refunded']) }
  scope :available_to_display, -> { available_to_count }
  scope :anonymous,            -> { where(anonymous: true) }
  scope :not_anonymous,        -> { where(anonymous: false) }
  scope :confirmed_today,      -> { with_state('confirmed').where("contributions.confirmed_at::date = current_timestamp::date ") }
  scope :can_cancel,           -> { where("contributions.can_cancel") }

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
    Reward.where(project_id: self.project_id)
  end

  def net_value
    value
  end
end
