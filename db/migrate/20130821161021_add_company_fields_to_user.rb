class AddCompanyFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :company_name, :string
    add_column :users, :company_logo, :string
  end
end
