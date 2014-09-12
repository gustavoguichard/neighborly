class RemoveUnsubscribes < ActiveRecord::Migration
  def up
    drop_table :unsubscribes
  end

  def down
    create_table :unsubscribes do |t|
      t.integer :user_id, null: false
      t.integer :project_id, null: false
      t.timestamps
    end
  end
end

