class AddCompanyContactIdToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :company_contact_id, :integer
  end
end
