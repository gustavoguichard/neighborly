class User < ActiveRecord::Base; end

class AddReferrerFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :referrer_id, :integer, foreign_key: { references: :users }
    add_column :users, :referral_code, :string

    reversible do |dir|
      dir.up do
        users = User.where(referral_code: nil) +
          User.where(referral_code: '')
        users.each do |user|
          user.update_attribute(:referral_code, SecureRandom.urlsafe_base64)
        end
      end
    end
  end
end
