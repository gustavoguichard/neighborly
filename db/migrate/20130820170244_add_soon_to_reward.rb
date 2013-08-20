class AddSoonToReward < ActiveRecord::Migration
  def change
    add_column :rewards, :soon, :boolean, default: false
  end
end
