class ActivityPolicy < ApplicationPolicy
  include ProjectInheritedPolicyHelpers

  def update?
    create?
  end

  def permitted_attributes
    { activity: [:title, :happened_at, :summary] }
  end
end
