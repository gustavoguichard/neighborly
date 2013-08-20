class AddFoundationWidgetToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :foundation_widget, :boolean, default: false
  end
end
