class AddHomePageToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :home_page, :boolean
  end
end
