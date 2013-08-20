class CreateProjectFaqs < ActiveRecord::Migration
  def change
    create_table :project_faqs do |t|
      t.text :answer
      t.text :title
      t.references :project, index: true

      t.timestamps
    end
  end
end
