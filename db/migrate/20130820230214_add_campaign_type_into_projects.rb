class AddCampaignTypeIntoProjects < ActiveRecord::Migration
  def change
    add_column :projects, :campaign_type, :text
  end
end
