class OauthProvider < ActiveRecord::Base
  has_many :authorizations
end
