class AddTermsIntoProject < ActiveRecord::Migration
  def change
    add_column :projects, :terms, :text
    add_column :projects, :terms_html, :text
  end
end
