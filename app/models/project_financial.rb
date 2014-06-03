class ProjectFinancial < ActiveRecord::Base
  acts_as_copy_target

  def readonly?
    true
  end
end
