class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def self.add_providers
    OauthProvider.all.each do |p|
      define_method p.name.downcase do
        omniauth = request.env['omniauth.auth']

        # The google oauth 2 is different because the migration of old
        # database, since we don't had the uid...
        # We can remove this when all users be with the uid saved.
        if p.name == 'google_oauth2'
            @user = User.
            select('users.*').
            joins('JOIN authorizations ON authorizations.user_id = users.id').
            joins('JOIN oauth_providers ON oauth_providers.id = authorizations.oauth_provider_id').
            where("users.email = :email AND oauth_providers.name = :provider", {email: omniauth['info']['email'], provider: p.name}).
            first || User.create_with_omniauth(omniauth, current_user)

            # Save the uid for old users that don't have it.
            # We can remove this when all users be with the uid saved.
            if @user
              authorization = @user.authorizations.where(provider: 'google_oauth2').first
              if authorization and not authorization.uid.present?
                authorization.uid = omniauth[:uid]
                authorization.save
              end
            end
        else
          @user = User.
            select('users.*').
            joins('JOIN authorizations ON authorizations.user_id = users.id').
            joins('JOIN oauth_providers ON oauth_providers.id = authorizations.oauth_provider_id').
            where("authorizations.uid = :uid AND oauth_providers.name = :provider", {uid: omniauth[:uid], provider: p.name}).
            first

            if @user.nil? and omniauth['info']['email']
              @user = User.create_with_omniauth(omniauth, current_user)
            end

            if @user.nil?
              session[:omniauth] = omniauth.except('extra')
              return render 'users/set_email', layout: 'catarse_bootstrap'
            end
        end

        flash[:notice] = I18n.t("devise.omniauth_callbacks.success", kind: p.name.capitalize)
        sign_in @user, event: :authentication
        if @user.email
          redirect_to(session[:return_to] || root_path)
          session[:return_to] = nil
        else
          render 'users/set_email', layout: 'catarse_bootstrap'
        end

        flash[:notice] = I18n.t("devise.omniauth_callbacks.success", kind: p.name.capitalize)
        sign_in @auth.user, event: :authentication
        redirect_to(session[:return_to] || root_path)
        session[:return_to] = nil
      end
    end
  end
end
