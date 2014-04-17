class ProjectFinancialsByService < ActiveRecord::Base
  belongs_to :project

  default_scope -> { order(:project_id) }

  def read_only?
    true
  end
end
