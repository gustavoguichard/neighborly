class AddApplicationUrlToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :application_url, :string
  end
end
