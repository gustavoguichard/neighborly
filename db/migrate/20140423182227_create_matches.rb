class CreateMatches < ActiveRecord::Migration
  def change
    create_table :matches do |t|
      t.references :project,       null: false, index: true
      t.references :user,                       index: true
      t.date       :starts_at,     null: false
      t.date       :finishes_at,   null: false
      t.decimal    :value_unit,    null: false
      t.decimal    :value
      t.boolean    :completed,     null: false, default: false

      t.string     :payment_id,                       foreign_key: false
      t.text       :payment_choice
      t.text       :payment_method
      t.text       :payment_token
      t.decimal    :payment_service_fee,              default: 0.0
      t.boolean    :payment_service_fee_paid_by_user, default: true
      t.string     :state

      t.timestamps
    end

    create_table :matchings do |t|
      t.references :match,        index: true
      t.references :contribution, index: true

      t.timestamps
    end

    add_column :contributions, :matching_id, :integer, index: true
  end
end
