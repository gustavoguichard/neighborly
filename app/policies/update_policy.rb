class UpdatePolicy < ApplicationPolicy
  include ProjectInheritedPolicyHelpers

  self::Scope = Struct.new(:user, :scope) do
    def resolve
      project = scope.proxy_association.owner

      if user && is_visible_for_user?(project)
        scope.load
      else
        scope.for_non_contributors
      end
    end

    private

    def is_visible_for_user?(project)
      (user.try(:admin) ||
       user.project_ids.include?(project.id) ||
       user.contributions.available_to_count.where(project_id: project.id).present?
      )
    end
  end

  def permitted_attributes
    { update: record.attribute_names.map(&:to_sym) }
  end
end
