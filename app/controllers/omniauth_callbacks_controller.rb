class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include OmniauthAuthenticationControllerHelpers

  def action_missing(method_name, *args, &block)
    @auth_providers ||= OauthProvider.pluck(:name)
    if @auth_providers.include? method_name.to_s
      oauth_callback_for(method_name.to_s)
    else
      raise ActionController::UrlGenerationError.new(nil)
    end
  end

  protected

  def oauth_callback_for(oauth_provider)
    omniauth_user = OmniauthUserSerializer.new(
      request.env.delete('omniauth.auth').merge(params: request.env['omniauth.params'])
    )

    omniauth_sign_in = OmniauthSignIn.new(current_user)
    omniauth_sign_in.complete(omniauth_user.to_h, session.delete(:new_user_attrs))

    complete_request_with(omniauth_sign_in)
  end
end
