class CreateMatches < ActiveRecord::Migration
  def change
    create_table :matches do |t|
      t.references :project,       null: false, index: true
      t.references :user,                       index: true
      t.date       :starts_at,     null: false
      t.date       :finishes_at,   null: false
      t.decimal    :value,         null: false
      t.decimal    :maximum_value

      t.string     :state
      t.string     :payment_id,                       foreign_key: false
      t.text       :payment_choice
      t.text       :payment_method
      t.text       :payment_token
      t.decimal    :payment_service_fee,              default: 0.0
      t.boolean    :payment_service_fee_paid_by_user

      t.timestamps
    end
  end
end
