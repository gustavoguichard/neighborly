class CreateAccessCodes < ActiveRecord::Migration
  def change
    create_table :access_codes do |t|
      t.string :code
      t.integer :max_users, default: 1

      t.timestamps
    end
  end
end
