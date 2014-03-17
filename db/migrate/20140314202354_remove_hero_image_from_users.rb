class RemoveHeroImageFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :hero_image, :string
  end
end
