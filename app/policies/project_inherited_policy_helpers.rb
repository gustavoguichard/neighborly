module ProjectInheritedPolicyHelpers
  def create?
    done_by_owner_or_admin?
  end

  def destroy?
    create?
  end
end
