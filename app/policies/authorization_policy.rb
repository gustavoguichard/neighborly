class AuthorizationPolicy < ApplicationPolicy
  def destroy?
    user.present? && ( record.user == user || is_admin?)
  end
end
