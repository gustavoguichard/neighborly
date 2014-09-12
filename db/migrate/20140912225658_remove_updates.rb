class RemoveUpdates < ActiveRecord::Migration
  def up
    remove_column :notifications, :update_id

    drop_table :updates
  end

  def down
    add_column :notifications, :update_id, :integer

    cteate_table :updates do |t|
      t.integer :user_id, null: false
      t.integer :project_id, null: false
      t.text :title
      t.text :comment
      t.text :comment_html
      t.boolean :exclusive
      t.timestamps
    end
  end
end
