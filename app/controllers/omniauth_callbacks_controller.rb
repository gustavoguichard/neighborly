class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def action_missing(method_name, *args, &block)
    @auth_providers ||= OauthProvider.pluck(:name)
    if @auth_providers.include? method_name.to_s
      oauth_callback_for(method_name.to_s)
    else
      super
    end
  end

  protected

  def oauth_callback_for(oauth_provider)
    omniauth_user    = OmniauthUserSerializer.new(request.env.delete('omniauth.auth'))
    omniauth_sign_in = OmniauthSignIn.new(current_user)
    omniauth_sign_in.complete(omniauth_user.to_h)

    complete_request_with(oauth_provider, omniauth_sign_in)
  end

  def complete_request_with(oauth_provider, omniauth_sign_in)
    {
      success: -> do
        sign_in omniauth_sign_in.user, event: :authentication

        flash.notice = flash_message(omniauth_sign_in.user, oauth_provider.capitalize)
        redirect_to after_sign_in_path_for(:user)
      end,
      needs_ownership_confirmation: -> do
        session[:new_user_attrs] = omniauth_sign_in.data

        flash[:devise_error] = 'We need you to confirm your password before proceed.'
        redirect_to new_user_session_path
      end,
      needs_email: -> do
        session[:new_user_attrs] = omniauth_sign_in.data

        redirect_to set_email_users_path
      end
    }.fetch(omniauth_sign_in.status).call
  end

  def flash_message(user, kind)
    if user.confirmed?
      t('devise.omniauth_callbacks.success', kind: kind)
    else
      t('devise.confirmations.send_instructions')
    end
  end
end
