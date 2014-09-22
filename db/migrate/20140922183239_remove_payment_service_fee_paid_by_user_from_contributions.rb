class RemovePaymentServiceFeePaidByUserFromContributions < ActiveRecord::Migration
  def change
    remove_column :contributions, :payment_service_fee_paid_by_user, :boolean, default: false
  end
end
