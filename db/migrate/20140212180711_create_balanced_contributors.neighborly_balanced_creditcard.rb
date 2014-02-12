# This migration comes from neighborly_balanced_creditcard (originally 20140211203335)
class CreateBalancedContributors < ActiveRecord::Migration
  def change
    create_table :balanced_contributors do |t|
      t.references :user, index: true
      t.string :uri
      t.string :credit_card_uri
      t.string :bank_account_uri

      t.timestamps
    end
  end
end
