class Authorization < ActiveRecord::Base
  belongs_to :user
  belongs_to :oauth_provider

  validates_presence_of :oauth_provider, :uid
end
