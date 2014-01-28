class ChangeNeighbourhoodToNeighborhood < ActiveRecord::Migration
  def change
    rename_column :contributions, :address_neighbourhood, :address_neighborhood
    rename_column :users, :address_neighbourhood, :address_neighborhood
  end
end
