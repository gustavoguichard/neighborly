class AddHasTagToProject < ActiveRecord::Migration
  def change
    add_column :projects, :hash_tag, :string
  end
end
