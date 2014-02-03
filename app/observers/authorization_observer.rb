class AuthorizationObserver < ActiveRecord::Observer
  observe :authorization

  def before_destroy(authorization)
    authorization.user.update_column column_name(authorization), nil
  end

  private
  def column_name(authorization)
    case authorization.oauth_provider.name
    when 'facebook'
      return :facebook_url
    when 'twitter'
      return :twitter_url
    when 'linkedin'
      return :linkedin_url
    end
  end
end
