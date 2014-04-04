class Authorization < ActiveRecord::Base
  belongs_to :user
  belongs_to :oauth_provider

  validates_presence_of :oauth_provider, :uid

  scope :from_hash, ->(hash){
    joins(:oauth_provider).where("oauth_providers.name = :name AND uid = :uid", { name: hash['provider'], uid: hash['uid'] })
  }

  scope :from_hash_without_uid, ->(hash){
    joins(:oauth_provider).where("oauth_providers.name = :name", { name: hash['provider'] }).joins(:user).where('users.email = :email', { email: hash['info']['email'] })
  }

  def update_access_token_from_hash(hash)
    send("update_access_token_from_hash_for_#{hash['provider']}", hash)
  rescue Exception => e
    Rails.logger.info "-----> #{e.inspect}"
  end

  private
  def update_access_token_from_hash_for_facebook(hash)
    self.update_attributes({ access_token: hash['credentials']['token'], access_token_expires_at: Time.at(hash['credentials']['expires_at'].to_i)} )
  end

  def update_access_token_from_hash_for_twitter(hash)
    self.update_attributes({ access_token: hash['credentials']['token'], access_token_secret: hash['credentials']['secret']} )
  end

  def update_access_token_from_hash_for_linkedin(hash)
    self.update_attributes({ access_token: hash['credentials']['token'], access_token_secret: hash['credentials']['secret'] })
  end

  def update_access_token_from_hash_for_google_oauth2(hash)
    self.update_attributes({ access_token: hash['credentials']['token'], access_token_secret: hash['credentials']['refresh_token'], access_token_expires_at: Time.at(hash['credentials']['expires_at'].to_i) })
  end
end
