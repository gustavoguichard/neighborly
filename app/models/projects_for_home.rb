class ProjectsForHome < ActiveRecord::Base
  self.table_name = 'projects_for_home'

  scope :featured,    -> { becomes_project where(origin: 'featured') }
  scope :recommends,  -> { becomes_project where(origin: 'recommended') }
  scope :expiring,    -> { becomes_project where(origin: 'expiring') }
  scope :soon,        -> { becomes_project where(origin: 'soon') }
  scope :successful,  -> { becomes_project where(origin: 'successful') }

  private
  def self.becomes_project(projects)
    projects.map { |p| p.becomes(Project) }
  end
end
