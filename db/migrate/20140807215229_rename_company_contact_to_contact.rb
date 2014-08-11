class RenameCompanyContactToContact < ActiveRecord::Migration
  def change
    if ActiveRecord::Base.connection.table_exists? 'contacts'
      drop_table :contacts
    end

    rename_column :notifications, :company_contact_id, :contact_id
    rename_table :company_contacts, :contacts
  end
end
