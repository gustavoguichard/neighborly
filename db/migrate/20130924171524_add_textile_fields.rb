class AddTextileFields < ActiveRecord::Migration
  def change
    add_column :projects, :about_textile, :text
    add_column :projects, :budget_textile, :text
    add_column :projects, :terms_textile, :text
    add_column :updates, :comment_textile, :text

  end
end
