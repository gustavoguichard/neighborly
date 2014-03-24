# This migration comes from neighborly_balanced (originally 20140324175041)
class AddBankAccountUriToBalancedContributors < ActiveRecord::Migration
  def change
    add_column :balanced_contributors, :bank_account_uri, :string
  end
end
