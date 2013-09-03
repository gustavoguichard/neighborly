class RemoveConstrinFromStateTable < ActiveRecord::Migration
  def up
    #execute("ALTER TABLE states DROP CONSTRAINT states_acronym_not_blank;")
    #execute("ALTER TABLE states DROP CONSTRAINT states_name_not_blank;")
    execute("ALTER TABLE states DROP CONSTRAINT states_name_unique;")
  end

  def down
  end
end
