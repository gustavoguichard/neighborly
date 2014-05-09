class AddMatchReferencesToPaymentNotification < ActiveRecord::Migration
  def change
    add_reference :payment_notifications, :match, index: true
  end
end
