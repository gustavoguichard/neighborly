module ProjectInheritedPolicyHelpers
  def create?
    done_by_owner_or_admin? || is_channel_admin?
  end

  def destroy?
    create?
  end

  def is_channel_admin?
    user.present? && ( record.project.last_channel.try(:user) == user ||
                        user.channels.include?(record.project.last_channel) )
  end

  # This method is used in ApplicationPolicy#done_by_owner_or_admin?
  def is_owned_by?(user)
    user.present? && record.project.user == user
  end
end
