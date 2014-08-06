class RenameMoreLinksToMoreUrls < ActiveRecord::Migration
  def change
    rename_column :projects, :more_links, :more_urls
  end
end
