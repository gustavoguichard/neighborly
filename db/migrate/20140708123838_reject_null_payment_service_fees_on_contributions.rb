class RejectNullPaymentServiceFeesOnContributions < ActiveRecord::Migration
  def change
    change_column_null :contributions, :payment_service_fee, false, 0
  end
end
