class CreateCompanyContacts < ActiveRecord::Migration
  def change
    create_table :company_contacts do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :phone
      t.string :company_name, null: false
      t.string :company_website
      t.text :message

      t.timestamps
    end
  end
end
