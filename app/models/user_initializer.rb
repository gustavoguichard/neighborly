class UserInitializer
  attr_reader :authorization, :omniauth_data

  def initialize(omniauth_data)
    @omniauth_data = omniauth_data

    check_required_attributes
  end

  def setup
    update_authorization_attributes
    update_user_attributes
  end

  def user
    authorization.try(:user)
  end

  def existing_user?
    !!@is_existing_user
  end

  protected

  def check_required_attributes
    @omniauth_data['info']          ||= {}
    @omniauth_data['info']['email'] ||= "change-your-email+#{Time.now.to_i}@neighbor.ly"
  end

  def update_authorization_attributes
    @authorization = Authorization.find_from_hash(omniauth_data)

    if @authorization.blank?
      @authorization    = Authorization.create_from_hash(omniauth_data)
    else
      @is_existing_user = true
      @authorization.update_access_token_from_hash(omniauth_data)
      if data['provider'] == 'google_oauth2'
        @authorization.update_uid_from_hash(data)
      end
    end
  end

  def update_user_attributes
    user.update_social_info(omniauth_data)
  end
end
