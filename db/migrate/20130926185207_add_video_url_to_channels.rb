class AddVideoUrlToChannels < ActiveRecord::Migration
  def up
    unless column_exists? :channels, :video_url
      add_column :channels, :video_url, :string
    end
  end

  def down
    remove_column :channels, :video_url
  end
end
