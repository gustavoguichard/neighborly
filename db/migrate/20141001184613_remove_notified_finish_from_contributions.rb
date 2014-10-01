class RemoveNotifiedFinishFromContributions < ActiveRecord::Migration
  def change
    remove_column :contributions, :notified_finish, :boolean, default: false
  end
end
