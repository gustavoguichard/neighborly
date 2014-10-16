module ProjectInheritedPolicyHelpers
  def index?
    if record.project.draft? || record.project.soon?
      create?
    else
      is_mvp_beta_user?
    end
  end

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
