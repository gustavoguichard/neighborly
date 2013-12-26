class RenameUserUrlFields < ActiveRecord::Migration
  def change
    rename_column :users, :twitter, :twitter_url
    rename_column :users, :facebook_link, :facebook_url
    rename_column :users, :other_link, :other_url
  end
end
