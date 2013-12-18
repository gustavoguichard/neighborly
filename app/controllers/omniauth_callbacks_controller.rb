class OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def self.add_providers
    OauthProvider.all.each do |p|
      define_method p.name.downcase do
        omniauth = request.env['omniauth.auth']
        @auth = authorization(omniauth)
        update_google_uid(@auth, omniauth['uid']) if omniauth['provider'] == 'google_oauth2'

        sign_in @auth.user, event: :authentication
        redirect_to(session[:return_to] || root_path, flash: { notice: flash_message(@auth.user, p.name.capitalize) })
        session[:return_to] = nil
      end
    end
  end

  add_providers if Rails.env.development?

  protected

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

  def update_google_uid(auth, uid)
    # Save the uid for old google users (openid)
    # We can remove this when all users be with the new uid saved.
    auth.update_attribute(:uid, uid)
  end

end
