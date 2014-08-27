class RenameCompanyToOrganizationInContacts < ActiveRecord::Migration
  def change
    rename_column :contacts, :company_name, :organization_name
    rename_column :contacts, :company_website, :organization_website
  end
end
