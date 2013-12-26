class RemoveSocialLinksFromChannel < ActiveRecord::Migration
  def change
    remove_column :channels, :twitter, :string
    remove_column :channels, :facebook, :string
    remove_column :channels, :website, :string
  end
end
