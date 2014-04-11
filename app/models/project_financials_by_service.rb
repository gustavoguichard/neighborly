class ProjectFinancialsByService < ActiveRecord::Base
  def read_only?
    true
  end
end
