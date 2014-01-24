class CompanyContact < ActiveRecord::Base
  schema_associations
  validates :first_name, :last_name, :email, :company_name, presence: true
end
