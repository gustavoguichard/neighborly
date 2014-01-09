class AddNameToProjectDocuments < ActiveRecord::Migration
  def change
    add_column :project_documents, :name, :string, required: true
  end
end
