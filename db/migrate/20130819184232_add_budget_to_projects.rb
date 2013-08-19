class AddBudgetToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :budget, :text
    add_column :projects, :budget_html, :text
  end
end
