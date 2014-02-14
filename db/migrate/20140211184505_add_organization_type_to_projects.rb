class AddOrganizationTypeToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :organization_type, :string
  end
end
