class OmniauthUserSerializer
  def initialize(omniauth_data)
    @omniauth_data = omniauth_data
  end

  def to_h
    {
      name:                      name,
      email:                     email,
      nickname:                  nickname,
      bio:                       bio,
      locale:                    locale,
      twitter_url:               twitter_url,
      linkedin_url:              linkedin_url,
      facebook_url:              facebook_url,
      remote_uploaded_image_url: remote_uploaded_image_url,
      authorizations_attributes: [authorization],
      investment_prospect_attributes: investment_prospect
    }.reject { |_key, value| value.blank? }
  end

  def investment_prospect
    { value: @omniauth_data['params'].try(:[], 'investment_prospect_value') }
  end

  def authorization
    {
      access_token:            access_token,
      access_token_expires_at: access_token_expires_at,
      access_token_secret:     access_token_secret,
      oauth_provider_id:       oauth_provider_id,
      uid:                     uid
    }.reject { |_key, value| value.blank? }
  end

  def name
    @omniauth_data['info']['name']
  end

  def email
    @omniauth_data['info']['email']
  end

  def nickname
    @omniauth_data['info']['nickname']
  end

  def bio
    @omniauth_data['info']['description'].try(:[], 0..139)
  end

  def locale
    I18n.locale.to_s
  end

  def uid
    @omniauth_data['uid']
  end

  def access_token
    @omniauth_data['credentials']['token']
  end

  def access_token_secret
    unless provider == 'facebook'
      @omniauth_data['credentials']['secret']
    end
  end

  def access_token_expires_at
    if %w(facebook google_oauth2).include? provider
      Time.at(@omniauth_data['credentials']['expires_at'].to_i)
    end
  end

  def oauth_provider_id
    OauthProvider.find_by(name: @omniauth_data['provider']).id
  end

  def provider
    @omniauth_data['provider']
  end

  def twitter_url
    "http://twitter.com/#{nickname}" if provider == 'twitter'
  end

  def linkedin_url
    @omniauth_data['info']['urls']['public_profile'] if provider == 'linkedin'
  end

  def facebook_url
    "http://facebook.com/#{nickname}" if provider == 'facebook'
  end

  def remote_uploaded_image_url
    if provider == 'facebook'
      "https://graph.facebook.com/#{uid}/picture?type=large"
    elsif @omniauth_data['info']['image'].present?
      @omniauth_data['info']['image']
    end
  end
end
