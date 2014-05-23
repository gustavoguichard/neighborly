class AddMatchReferencesToNotifications < ActiveRecord::Migration
  def change
    add_reference :notifications, :match, index: true
  end
end
