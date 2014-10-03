module Shared::PaymentStateMachineHandler
  extend ActiveSupport::Concern

  included do
    state_machine :state, initial: :pending do
      state :pending, :waiting_confirmation, :confirmed, :canceled,
            :refunded, :refunded_and_canceled, :deleted, :waiting_broker

      event :push_to_trash do
        transition all => :deleted
      end

      event :pendent do
        transition all - [:pending] => :pending
      end

      event :wait_confirmation do
        transition pending: :waiting_confirmation
      end

      event :wait_broker do
        transition pending: :waiting_broker
      end

      event :confirm do
        transition all - [:confirmed] => :confirmed
      end

      event :cancel do
        transition all - [:canceled] => :canceled
      end

      event :refund do
        transition [:confirmed] => :refunded
      end

      event :hide do
        transition all => :refunded_and_canceled
      end

      after_transition do |resource, transition|
        resource.notify_observers "from_#{transition.from}_to_#{transition.to}".to_sym
      end
    end
  end
end
