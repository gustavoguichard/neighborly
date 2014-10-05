class FixCategoryNameFields < ActiveRecord::Migration
  def change
    remove_column :categories, :name_pt, :string
    rename_column :categories, :name_en, :name
    change_column_null :categories, :name, false
  end
end
