class CreatePayouts < ActiveRecord::Migration
  def change
    create_table :payouts do |t|
      t.string     :payment_service
      t.references :project,           index: true, null: false
      t.references :user,              index: true
      t.integer    :value,   limit: 8,              null: false

      t.timestamps
    end
  end
end
