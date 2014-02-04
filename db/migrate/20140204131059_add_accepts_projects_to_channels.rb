class AddAcceptsProjectsToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :accepts_projects, :boolean, default: true
  end
end
