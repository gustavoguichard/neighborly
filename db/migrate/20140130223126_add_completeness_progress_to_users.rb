class AddCompletenessProgressToUsers < ActiveRecord::Migration
  def change
    add_column :users, :completeness_progress, :integer, default: 0
  end
end
