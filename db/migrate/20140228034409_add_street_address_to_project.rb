class AddStreetAddressToProject < ActiveRecord::Migration
  def change
    add_column :projects, :street_address, :string
  end
end
