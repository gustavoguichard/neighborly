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

    if not_sold_yet?
      attributes = attributes.concat(%i(
        cusip_number
        interest_rate
        price
        principal_amount
        yield
      ))
    end

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
