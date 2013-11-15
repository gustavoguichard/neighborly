class AddBackgroundToProject < ActiveRecord::Migration
  def change
    add_column :projects, :background, :string
  end
end
