class Contribution < ActiveRecord::Base
  include Shared::StateMachineHelpers,
          Shared::PaymentStateMachineHandler,
          Contribution::CustomValidators,
          Shared::Notifiable,
          Shared::Payable,
          PgSearch

  FEE_PER_BOND = 3

  belongs_to :user
  belongs_to :project
  belongs_to :reward

  validates_presence_of :project, :user, :value

  scope :available_to_count,   -> { with_states(['confirmed', 'refunded']) }
  scope :available_to_display, -> { available_to_count }
  scope :anonymous,            -> { where(anonymous: true) }
  scope :not_anonymous,        -> { where(anonymous: false) }
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

  def refund_deadline
    created_at + 180.days
  end

  def available_rewards
    Reward.where(project_id: self.project_id)
  end

  def net_value
    value
  end

  def platform_fee
    FEE_PER_BOND * bonds
  end

  def gross_value(payment_method = nil)
    payment_method ||= read_attribute(:payment_method) || (raise ArgumentError)
    calculator = {
      'balanced-bankaccount' => Neighborly::Balanced::Bankaccount::Interface,
    }.fetch(payment_method).new.fee_calculator(net_value, platform_fee)

    net_value + calculator.processor_fee + calculator.platform_fee
  end
end
