class SessionsController < Devise::SessionsController
  after_filter :attach_omniauth_authorization, only: :create

  protected

  def attach_omniauth_authorization
    authorization_email = session.delete(:orphan_authorization_email)
    authorization_id    = session.delete(:orphan_authorization)
    unless authorization_id && current_user.email.eql?(authorization_email)
      return
    end

    authorization = Authorization.find(authorization_id)
    authorization.update_attributes(user: current_user)
  end
end
