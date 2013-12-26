class RemoveChannelIdFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :channel_id, :integer
  end
end
