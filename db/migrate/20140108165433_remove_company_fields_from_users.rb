class RemoveCompanyFieldsFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :company_name, :string
    remove_column :users, :company_logo, :string
  end
end
