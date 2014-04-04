class SessionsController < Devise::SessionsController
  include OmniauthAuthenticationControllerHelpers

  after_filter :attach_omniauth_authorization,
    only: :create,
    if: -> { session.has_key?(:new_user_attrs) }

  def confirm_new_user_email
    session[:new_user_attrs]       ||= {}
    session[:new_user_attrs][:email] = params.fetch(:user).fetch(:email)

    complete_request_with(attach_omniauth_authorization)
  end

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
