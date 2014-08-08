class RenameCompanyContactToContact < ActiveRecord::Migration
  def change
    rename_column :notifications, :company_contact_id, :contact_id
    rename_table :company_contacts, :contacts
  end
end
