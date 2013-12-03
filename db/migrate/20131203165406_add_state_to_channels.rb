class AddStateToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :state, :text, default: 'draft'
  end
end
