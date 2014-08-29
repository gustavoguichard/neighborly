class AddProjectProposalUrlToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :project_proposal_url, :string
  end
end
