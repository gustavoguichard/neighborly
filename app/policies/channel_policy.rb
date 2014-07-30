class ChannelPolicy < ApplicationPolicy
  def admin?
    user.present? && (record.user == user ||
                      record.members.include?(user) ||
                      is_admin?
                     )
  end

  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.admin?
        scope
      else
        owned = scope.where(user: user)
        membered = scope.where(id: user.channels.map(&:id))
        online = scope.with_state('online')
        scope.from("(#{owned.to_sql} UNION #{membered.to_sql} UNION #{online.to_sql}) as channels")
      end
    end
  end
end
