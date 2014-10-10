class AddAccessCodeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :access_code_id, :integer
  end
end
