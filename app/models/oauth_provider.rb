class OauthProvider < ActiveRecord::Base
  has_many :authorizations, dependent: :destroy
end
