class ProjectDocumentPolicy < ApplicationPolicy
  include ProjectInheritedPolicyHelpers

  def permitted_attributes
    { project_document: record.attribute_names.map(&:to_sym) }
  end
end
