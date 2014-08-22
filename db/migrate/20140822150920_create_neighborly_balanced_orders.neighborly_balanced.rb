# This migration comes from neighborly_balanced (originally 20140817195359)
class CreateNeighborlyBalancedOrders < ActiveRecord::Migration
  def change
    create_table :neighborly_balanced_orders do |t|
      t.references :project, index: true, null: false
      t.string :href, null: false

      t.timestamps
    end
  end
end
