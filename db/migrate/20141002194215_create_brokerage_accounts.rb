class CreateBrokerageAccounts < ActiveRecord::Migration
  def change
    create_table :brokerage_accounts do |t|
      t.string :name, null: false
      t.string :address, null: false
      t.string :tax_id, null: false, foreign_key: false
      t.string :email, null: false
      t.string :phone, null: false
      t.references :user, index: true

      t.timestamps
    end
  end
end
