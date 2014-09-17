class RewardPolicy < ApplicationPolicy
  include ProjectInheritedPolicyHelpers

  def update?
    create?
  end

  def sort?
    create?
  end

  def destroy?
    create? && not_sold_yet?
  end

  def permitted_attributes
    attributes = record.attribute_names.map(&:to_sym)

    { reward: attributes }
  end

  protected
  def not_sold_yet?
    record.try(:total_compromised) == 0
  end

  def project_finished?
    record.project.successful?
  end
end
