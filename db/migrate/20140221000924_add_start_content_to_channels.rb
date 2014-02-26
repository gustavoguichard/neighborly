class AddStartContentToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :start_content, :hstore
  end
end
