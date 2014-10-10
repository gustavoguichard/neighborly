class AuthorizationObserver < ActiveRecord::Observer
  def before_destroy(authorization)
    authorization.user.update_column column_name(authorization), nil
  end

  def after_commit(authorization)
    Webhook::EventRegister.new(authorization, created: just_created?(authorization))
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

  def just_created?(authorization)
    !!authorization.send(:transaction_record_state, :new_record)
  end
end
