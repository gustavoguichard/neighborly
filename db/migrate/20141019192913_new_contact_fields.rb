class NewContactFields < ActiveRecord::Migration
  def change
    remove_column :contacts, :organization_name, :string
    remove_column :contacts, :organization_website, :string
    add_column :contacts, :subject, :string
  end
end
