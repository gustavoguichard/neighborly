class AccessCode < ActiveRecord::Base
  validates :code, presence: true
  has_many :users

  def still_valid?
    users.count < max_users
  end
end
