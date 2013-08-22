class AddShortNoteIntoBackers < ActiveRecord::Migration
  def change
    add_column :backers, :short_note, :text
  end
end
