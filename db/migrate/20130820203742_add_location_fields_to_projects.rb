class AddLocationFieldsToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :address_city, :string
    add_column :projects, :address_state, :string
    add_column :projects, :address_zip_code, :string
    add_column :projects, :address_neighborhood, :string
  end
end
