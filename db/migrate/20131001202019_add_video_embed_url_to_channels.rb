class AddVideoEmbedUrlToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :video_embed_url, :string
  end
end
