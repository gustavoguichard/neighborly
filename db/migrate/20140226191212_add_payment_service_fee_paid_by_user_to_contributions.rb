class AddPaymentServiceFeePaidByUserToContributions < ActiveRecord::Migration
  def change
    change_column_default :contributions, :payment_service_fee, 0
    add_column :contributions, :payment_service_fee_paid_by_user, :boolean, default: false
  end
end
