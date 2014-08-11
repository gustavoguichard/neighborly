class RenameCompanyContactToContact < ActiveRecord::Migration
  def up
    if ActiveRecord::Base.connection.table_exists? 'contacts'
      drop_table :contacts
    end

    rename_column :notifications, :company_contact_id, :contact_id
    rename_table :company_contacts, :contacts
  end

  def down
    rename_column :notifications, :contact_id, :company_contact_id
    rename_table :contacts, :company_contacts
  end
end
