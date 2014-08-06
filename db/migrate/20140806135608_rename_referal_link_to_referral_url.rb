class RenameReferalLinkToReferralUrl < ActiveRecord::Migration
  def change
    rename_column :contributions, :referal_link, :referral_url
    rename_column :projects, :referal_link, :referral_url
  end
end
