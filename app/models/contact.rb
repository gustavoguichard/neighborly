class Contact < ActiveRecord::Base
  has_many :notifications
  validates :first_name, :last_name, :email, :organization_name, presence: true
end
