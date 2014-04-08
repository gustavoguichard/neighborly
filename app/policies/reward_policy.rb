class RewardPolicy < ApplicationPolicy
  def create?
    done_by_owner_or_admin? || is_channel_admin?
  end

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

    if record.instance_of?(Reward)
      attributes.delete(:minimum_value) unless not_sold_yet?
      attributes.delete(:days_to_delivery) if project_finished?
    end

    { reward: attributes }
  end

  protected
  def not_sold_yet?
    record.try(:total_compromised) == 0
  end

  def project_finished?
    record.project.failed? || record.project.successful?
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
