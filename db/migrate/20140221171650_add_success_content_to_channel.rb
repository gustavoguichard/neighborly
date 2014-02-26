class AddSuccessContentToChannel < ActiveRecord::Migration
  def change
    add_column :channels, :success_content, :hstore
  end
end
