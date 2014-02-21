class AddStartHeroImageToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :start_hero_image, :string
  end
end
