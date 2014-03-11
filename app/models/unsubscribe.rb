class Unsubscribe < ActiveRecord::Base
  attr_accessor :subscribed
  belongs_to :user
  belongs_to :project

  def self.updates_unsubscribe project_id
    find_or_initialize_by(project_id: project_id)
  end
end
