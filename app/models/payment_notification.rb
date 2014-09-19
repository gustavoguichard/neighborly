class PaymentNotification < ActiveRecord::Base
  belongs_to :contribution
  serialize :extra_data, JSON
end
