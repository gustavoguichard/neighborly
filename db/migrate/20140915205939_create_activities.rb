class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.string :title, null: false
      t.datetime :happened_at, null: false
      t.string :summary
      t.references :project, index: true
      t.references :user, index: true

      t.timestamps
    end
  end
end
