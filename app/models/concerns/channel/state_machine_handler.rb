module Channel::StateMachineHandler
  extend ActiveSupport::Concern

  included do
    state_machine :state, initial: :draft do
      state :draft
      state :online

      event :push_to_draft do
        transition all => :draft #NOTE: when use 'all' we can't use new hash style ;(
      end

      event :push_to_online do
        transition draft: :online
      end
    end
  end
end
