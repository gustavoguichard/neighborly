class AddExternalIdToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :external_id, :string, foreign_key: false
  end
end
