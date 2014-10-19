class BrokerageAccount < ActiveRecord::Base
  belongs_to :user

  validates :address, :email, :name, :user, :tax_id, presence: true
end
