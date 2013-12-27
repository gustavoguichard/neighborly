class CreateChannelMembers < ActiveRecord::Migration
  def change
    create_table :channel_members do |t|
      t.references :channel, index: true
      t.references :user, index: true
      t.boolean :admin, default: false

      t.timestamps
    end
  end
end
