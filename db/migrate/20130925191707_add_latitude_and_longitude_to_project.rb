class AddLatitudeAndLongitudeToProject < ActiveRecord::Migration
  def up
    add_column :projects, :latitude, :float
    add_column :projects, :longitude, :float
    add_index :projects, [:latitude, :longitude]
  end
end
