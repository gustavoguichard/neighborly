class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :name
      t.string :image
      t.references :user, index: true, required: true

      t.timestamps
    end
  end
end
