class UserInitializer
  attr_reader :authorization, :omniauth_data, :provider, :email

  def initialize(provider, omniauth_data)
    @provider, @omniauth_data = provider, omniauth_data

    check_required_attributes
  end

  def setup
    update_authorization_attributes
    update_user_attributes
  end

  def user
    @authorization.try(:user)
  end

  def no_account_conflicts?
    @has_no_account_conflicts ||= @email && !User.find_by(email: @email)
  end

  protected

  def fill_required_attributes
    @omniauth_data['info']          = {}
    @omniauth_data['info']['email'] = "change-your-email+#{Time.now.to_i}@neighbor.ly"
  end

  def update_authorization_attributes
    @authorization = Authorization.find_from_hash(omniauth_data)

    if @authorization.blank?
      @authorization = Authorization.create_from_hash(omniauth_data)
    else
      @authorization.update_access_token_from_hash(omniauth_data)
      if provider.eql? 'google_oauth2'
        @authorization.update_uid_from_hash(omniauth_data)
      end
    end
  end

  def update_user_attributes
    user.update_social_info(omniauth_data)
  end
end
