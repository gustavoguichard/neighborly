module ProjectInheritedPolicyHelpers
  def create?
    done_by_owner_or_admin?
  end

  def destroy?
    create?
  end

  # This method is used in ApplicationPolicy#done_by_owner_or_admin?
  def is_owned_by?(user)
    user.present? && record.project.user == user
  end
end
