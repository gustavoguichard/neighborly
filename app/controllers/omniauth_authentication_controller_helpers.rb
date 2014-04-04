module OmniauthAuthenticationControllerHelpers
  extend ActiveSupport::Concern

  def complete_request_with(omniauth_sign_in)
    {
      success: -> do
        sign_in omniauth_sign_in.user, event: :authentication

        flash.notice = flash_message(omniauth_sign_in.user, omniauth_sign_in.provider.capitalize)
        redirect_to after_sign_in_path_for(:user)
      end,
      needs_ownership_confirmation: -> do
        session[:new_user_attrs] = omniauth_sign_in.data

        flash[:devise_error] = 'We need you to confirm your password before proceed.'
        flash[:user_email]   = session[:new_user_attrs][:email]
        redirect_to new_user_session_path
      end,
      needs_email: -> do
        session[:new_user_attrs] = omniauth_sign_in.data

        redirect_to set_new_user_email_path
      end
    }.fetch(omniauth_sign_in.status).call
  end
end
