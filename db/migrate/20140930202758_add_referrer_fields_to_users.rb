class AddReferrerFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :referrer_id, :integer, foreign_key: { references: :users }
    add_column :users, :referral_code, :string
  end
end
