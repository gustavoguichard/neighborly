class ProjectFaqPolicy < ApplicationPolicy
  include ProjectInheritedPolicyHelpers

  def permitted_attributes
    { project_faq: record.attribute_names.map(&:to_sym) }
  end
end
