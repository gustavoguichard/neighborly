class ChangeNullPhoneOnBrokerageAccount < ActiveRecord::Migration
  def change
    change_column_null :brokerage_accounts, :phone, true
  end
end
