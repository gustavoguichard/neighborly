class AddTitleToRewards < ActiveRecord::Migration
  def change
    add_column :rewards, :title, :string, null: false, default: ''
  end
end
