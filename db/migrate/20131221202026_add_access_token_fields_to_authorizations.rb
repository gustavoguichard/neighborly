class AddAccessTokenFieldsToAuthorizations < ActiveRecord::Migration
  def change
    add_column :authorizations, :access_token, :string
    add_column :authorizations, :access_token_secret, :string
    add_column :authorizations, :access_token_expires_at, :datetime
  end
end
