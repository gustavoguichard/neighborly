class AddSiteToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :site, :string
  end
end
