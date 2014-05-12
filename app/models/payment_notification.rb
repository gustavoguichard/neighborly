class PaymentNotification < ActiveRecord::Base
  belongs_to :match
  belongs_to :contribution
  serialize :extra_data, JSON
end
