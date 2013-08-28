class AddNewProjectToUsers < ActiveRecord::Migration
  def change
    add_column :users, :new_project, :boolean, default: false
  end
end
