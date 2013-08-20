class ProjectFaq < ActiveRecord::Base
  attr_accessible :answer, :project_id, :title, :project

  belongs_to :project

  validates :answer, :project, :title, presence: true
end
