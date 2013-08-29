class CreateRoutingNumbers < ActiveRecord::Migration
  def change
    create_table :routing_numbers do |t|
      t.string :number
      t.string :bank_name

      t.timestamps
    end
  end
end
