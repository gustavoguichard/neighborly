module Channel::StateMachineHandler
  extend ActiveSupport::Concern

  included do
    state_machine :state, initial: :draft do
      state :draft, value: 'draft'
      state :online, value: 'online'


      event :push_to_draft do
        transition all => :draft #NOTE: when use 'all' we can't use new hash style ;(
      end

      event :push_to_online do
        transition draft: :online
      end
    end
  end
end
