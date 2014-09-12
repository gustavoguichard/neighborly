module Shared::PaymentStateMachineHandler
  extend ActiveSupport::Concern

  included do
    state_machine :state, initial: :pending do
      state :pending
      state :waiting_confirmation
      state :confirmed
      state :canceled
      state :refunded
      state :refunded_and_canceled
      state :deleted

      event :push_to_trash do
        transition all => :deleted
      end

      event :pendent do
        transition all - [:pending] => :pending
      end

      event :wait_confirmation do
        transition pending: :waiting_confirmation
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

        if resource.is_a? Contribution
          MatchedContributionGenerator.new(resource).update
        end
      end
    end
  end
end
