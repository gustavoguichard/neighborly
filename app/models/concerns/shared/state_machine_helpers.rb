require 'state_machine'
module Shared
  module StateMachineHelpers
    extend ActiveSupport::Concern

    included do
      def self.state_names
        self.state_machine.states.map(&:name).reject { |n| n == :deleted }
      end
    end
  end
end
