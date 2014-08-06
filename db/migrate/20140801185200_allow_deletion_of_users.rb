class AllowDeletionOfUsers < ActiveRecord::Migration
  CONSTRAINTS = {
    api_access_tokens:     :fk_api_access_tokens_user_id,
    authorizations:        :fk_authorizations_user_id,
    balanced_contributors: :fk_balanced_contributors_user_id,
    channel_members:       :fk_channel_members_user_id,
    channels_subscribers:  :fk_channels_subscribers_user_id,
    images:                :fk_images_user_id,
    organizations:         :fk_organizations_user_id,
    notifications:         :notifications_user_id_reference,
    unsubscribes:          :unsubscribes_user_id_fk,
    updates:               :updates_user_id_fk
  }

  def up
    drop_constraints
    create_constraints(' ON DELETE CASCADE')

    execute <<-SQL
      CREATE RULE prevent_deletion_of_recommendations AS ON DELETE TO recommendations
          DO INSTEAD NOTHING;
    SQL
  end

  def down
    drop_constraints
    create_constraints

    execute <<-SQL
      DROP RULE prevent_deletion_of_recommendations ON recommendations;
    SQL
  end

  private

  def drop_constraints
    execute CONSTRAINTS.map { |table, constraint|
      "ALTER TABLE #{table} DROP CONSTRAINT #{constraint};"
    }.join
  end

  def create_constraints(options = '')
    execute CONSTRAINTS.map { |table, constraint|
      <<-SQL
        ALTER TABLE ONLY #{table}
          ADD CONSTRAINT #{constraint} FOREIGN KEY (user_id)
            REFERENCES users(id)#{options};
      SQL
    }.join
  end
end
