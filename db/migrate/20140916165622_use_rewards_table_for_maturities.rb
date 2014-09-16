class UseRewardsTableForMaturities < ActiveRecord::Migration
  def up
    remove_column :rewards, :minimum_value
    remove_column :rewards, :description
    remove_column :rewards, :reindex_versions
    remove_column :rewards, :days_to_delivery
    remove_column :rewards, :soon
    remove_column :rewards, :title

    add_column :rewards, :happens_at, :date
    add_column :rewards, :principal_amount, :decimal
    add_column :rewards, :interest_rate, :decimal
    add_column :rewards, :yield, :decimal
    add_column :rewards, :price, :decimal
    add_column :rewards, :cusip_number, :string
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
