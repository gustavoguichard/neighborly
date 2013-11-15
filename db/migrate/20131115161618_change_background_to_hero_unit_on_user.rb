class ChangeBackgroundToHeroUnitOnUser < ActiveRecord::Migration
  def change
    rename_column :users, :background, :hero_image
  end
end
