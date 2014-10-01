module Project::StateMachineHandler
  extend ActiveSupport::Concern

  included do
    state_machine :state, initial: :draft do
      state :draft, :soon, :rejected, :online, :successful, :waiting_funds, :deleted

      event :push_to_draft do
        transition all => :draft #NOTE: when use 'all' we can't use new hash style ;(
      end

      event :approve do
        transition [:draft, :rejected] => :soon
      end

      event :push_to_trash do
        transition [:draft, :rejected] => :deleted
      end

      event :reject do
        transition [:draft] =>  :rejected
      end

      event :launch do
        transition [:draft, :soon] => :online
      end

      event :finish do
        transition online: :waiting_funds,        if: ->(project) {
          project.expired? && project.pending_contributions_reached_the_goal?
        }

        transition waiting_funds: :successful,    if: ->(project) {
          !project.in_time_to_wait?
        }

        transition waiting_funds: :waiting_funds, if: ->(project) {
          project.expired? && !project.reached_goal? && (project.in_time_to_wait?)
        }
      end

      after_transition do |project, transition|
        project.notify_observers :"from_#{transition.from}_to_#{transition.to}"
      end

      after_transition any => [:successful] do |project, transition|
        project.notify_observers :sync_with_mailchimp
      end

      after_transition [:draft, :rejected] => :deleted do |project, transition|
        project.update_attributes({ permalink: "deleted_project_#{project.id}"})
      end
    end
  end
end

