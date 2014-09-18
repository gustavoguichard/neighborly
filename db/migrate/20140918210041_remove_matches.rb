class RemoveMatches < ActiveRecord::Migration
  def change
    remove_column :project_totals, :total_contributions_without_matches, :integer, default: 0
    remove_column :contributions, :matching_id, :integer
    remove_column :notifications, :match_id, :integer
    remove_column :payment_notifications, :match_id, :integer

    drop_table :matchings do |t|
      t.references :match,        index: true
      t.references :contribution, index: true

      t.timestamps
    end

    drop_table :matches do |t|
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
  end
end
