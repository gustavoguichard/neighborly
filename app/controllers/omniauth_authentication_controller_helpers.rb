module OmniauthAuthenticationControllerHelpers
  extend ActiveSupport::Concern

  def complete_request_with(omniauth_sign_in)
    {
      success: -> do
        sign_in omniauth_sign_in.user, event: :authentication

        flash.notice = login_flash_message(omniauth_sign_in.user, omniauth_sign_in.provider_name.capitalize)
        redirect_to after_sign_in_path_for(:user)
      end,
      needs_ownership_confirmation: -> do
        session[:new_user_attrs] = omniauth_sign_in.data

        flash.alert = t('needs_ownership_confirmation',
          scope: 'controllers.omniauth_authentication')
        flash[:user_email]   = session[:new_user_attrs].try(:[], :email)
        redirect_to new_user_session_path
      end,
      needs_email: -> do
        session[:new_user_attrs] = omniauth_sign_in.data

        redirect_to set_new_user_email_path
      end
    }.fetch(omniauth_sign_in.status).call
  end

  def login_flash_message(user, kind)
    if user.confirmed?
      t('devise.omniauth_callbacks.success', kind: kind)
    else
      t('devise.confirmations.send_instructions')
    end
  end
end
