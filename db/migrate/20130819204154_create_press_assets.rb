class CreatePressAssets < ActiveRecord::Migration
  def change
    create_table :press_assets do |t|
      t.string :title
      t.text :image
      t.string :url

      t.timestamps
    end
  end
end
