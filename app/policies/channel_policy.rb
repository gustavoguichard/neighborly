class ChannelPolicy < ApplicationPolicy
 def admin?
   user.present? && (record.user == user ||
                     record.members.include?(user) ||
                     is_admin?
                    )
 end
end
