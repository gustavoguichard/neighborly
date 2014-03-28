class ChannelPolicy < ApplicationPolicy
 def admin?
   user.present? && (record.user == user ||
                     record.members.include?(user)
                    )
 end
end
