class AddSaleDateToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :sale_date, :datetime
  end
end
