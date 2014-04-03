class RemoveShowContactButtonFromRewards < ActiveRecord::Migration
  def change
    remove_column :rewards, :show_contact_button, :boolean, default: false
  end
end
