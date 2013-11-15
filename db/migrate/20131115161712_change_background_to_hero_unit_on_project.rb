class ChangeBackgroundToHeroUnitOnProject < ActiveRecord::Migration
  def change
    rename_column :projects, :background, :hero_image
  end
end
