class ProjectFaq < ActiveRecord::Base
  belongs_to :project

  validates :answer, :project, :title, presence: true
end
