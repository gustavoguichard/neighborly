class AddBondsToContribution < ActiveRecord::Migration
  def change
    add_column :contributions, :bonds, :integer, null: false, default: 1
  end
end
