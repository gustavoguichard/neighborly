class CreateProjectDocuments < ActiveRecord::Migration
  def change
    create_table :project_documents do |t|
      t.text :document
      t.references :project, index: true

      t.timestamps
    end
  end
end
