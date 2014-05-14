class PaymentObserver < ActiveRecord::Observer
  observe :contribution, :match
end
