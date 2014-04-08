class UpdatePolicy < ApplicationPolicy
  include ProjectInheritedPolicyHelpers

  def permitted_attributes
    { update: record.attribute_names.map(&:to_sym) }
  end
end
