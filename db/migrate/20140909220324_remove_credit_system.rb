class Contribution < ActiveRecord::Base; end

class RemoveCreditSystem < ActiveRecord::Migration
  def up
    drop_view :user_totals
    execute 'DROP FUNCTION can_refund(contributions)'
    remove_column :contributions, :credits
    Contribution.where(state: :requested_refund).update_all(state: :deleted)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
