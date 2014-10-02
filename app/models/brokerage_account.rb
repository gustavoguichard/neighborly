class BrokerageAccount < ActiveRecord::Base
  belongs_to :user

  validates :address, :email, :name, :phone, :user, :tax_id, presence: true
end
