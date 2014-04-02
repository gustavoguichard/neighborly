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
    omniauth_sign_in = OmniauthSignIn.new(current_user, oauth_provider)
    omniauth_sign_in.complete(request.env['omniauth.auth'])
    if omniauth_sign_in.existing_user?
      sign_in omniauth_sign_in.user, event: :authentication

      flash.notice = flash_message(omniauth_sign_in.user, oauth_provider.capitalize)
      redirect_to after_sign_in_path_for(:user)
    else
      flash[:devise_error] = 'Sign to complete'
      redirect_to new_user_session_path
    end
  end

  def flash_message(user, kind)
    if user.confirmed?
      t('devise.omniauth_callbacks.success', kind: kind)
    else
      t('devise.confirmations.send_instructions')
    end
  end
end
