class AddSubmitYourProjectTextToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :submit_your_project_text, :text
    add_column :channels, :submit_your_project_text_html, :text
  end
end
