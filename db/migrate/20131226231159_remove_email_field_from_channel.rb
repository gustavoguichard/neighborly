class RemoveEmailFieldFromChannel < ActiveRecord::Migration
  def change
    remove_column :channels, :email, :string
  end
end
