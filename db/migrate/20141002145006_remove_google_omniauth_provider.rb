class RemoveGoogleOmniauthProvider < ActiveRecord::Migration
  def up
    execute <<-SQL
      ALTER TABLE authorizations DROP CONSTRAINT fk_authorizations_oauth_provider_id;

      ALTER TABLE ONLY authorizations
          ADD CONSTRAINT fk_authorizations_oauth_provider_id FOREIGN KEY (oauth_provider_id)
            REFERENCES oauth_providers(id) ON DELETE CASCADE;
    SQL

    OauthProvider.find_by(name: :google_oauth2).try(:delete)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
