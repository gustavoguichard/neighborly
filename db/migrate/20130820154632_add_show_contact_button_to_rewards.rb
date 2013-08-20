class AddShowContactButtonToRewards < ActiveRecord::Migration
  def change
    add_column :rewards, :show_contact_button, :boolean, default: false
  end
end
