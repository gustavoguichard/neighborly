# Be sure to restart your server when you modify this file.
if ActiveRecord::Base.connection.tables.include?(::Configuration.table_name)
  if Rails.env.production? && Configuration[:base_domain]
    Neighborly::Application.config.session_store :cookie_store, key: Configuration[:secret_token], domain: Configuration[:base_domain]
  else
    Neighborly::Application.config.session_store :cookie_store, key: Configuration[:secret_token]
  end
end
