class AddProfileTypeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :profile_type, :string
  end
end
