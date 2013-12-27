class OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def self.add_providers
    OauthProvider.all.each do |p|
      define_method p.name.downcase do
        omniauth = request.env['omniauth.auth']
        @auth = authorization(omniauth)
        update_informations(@auth, omniauth)

        sign_in @auth.user, event: :authentication unless current_user
        redirect_to(session[:return_to] || root_path, flash: { notice: flash_message(@auth.user, p.name.capitalize) })
        session[:return_to] = nil
      end
    end
  end

  add_providers if Rails.env.development?

  protected

  def update_informations(auth, omniauth)
    auth = Authorization.find(auth.id)
    auth.user.update_social_info(omniauth)
    auth.update_access_token_from_hash(omniauth)
    auth.update_uid_from_hash(omniauth) if omniauth['provider'] == 'google_oauth2'
    auth
  end

  def authorization(omniauth)
    unless (auth = Authorization.find_from_hash(omniauth))
      user = current_user || (User.find_by_email(omniauth[:info][:email]) rescue nil)
      auth = omniauth[:info][:email].present? ? Authorization.create_from_hash(omniauth, user) : Authorization.create_without_email_from_hash(omniauth, user)
    end
    auth
  end

  def flash_message(user, kind)
    if user.confirmed?
      t('devise.omniauth_callbacks.success', kind: kind)
    else
      t('devise.confirmations.send_instructions')
    end
  end
end
