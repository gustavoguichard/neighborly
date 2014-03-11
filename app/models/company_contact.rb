class CompanyContact < ActiveRecord::Base
  has_many :notifications
  validates :first_name, :last_name, :email, :company_name, presence: true
end
