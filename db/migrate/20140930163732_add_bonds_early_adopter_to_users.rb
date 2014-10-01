class AddBondsEarlyAdopterToUsers < ActiveRecord::Migration
  def change
    add_column :users, :bonds_early_adopter, :boolean, null: false, default: false
  end
end
