class AddKeyAndConfirmedAtToMatches < ActiveRecord::Migration
  def change
    add_column :matches, :key, :string
    add_column :matches, :confirmed_at, :datetime
  end
end
