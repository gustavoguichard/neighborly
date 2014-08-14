class CreateInvestmentProspects < ActiveRecord::Migration
  def change
    create_table :investment_prospects do |t|
      t.references :user, index: true
      t.float :value, default: 0

      t.timestamps
    end
  end
end
