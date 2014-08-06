class RemoveMoipLoginFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :moip_login, :string
  end
end
