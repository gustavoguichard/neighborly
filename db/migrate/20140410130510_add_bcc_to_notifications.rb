class AddBccToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :bcc, :string
  end
end
