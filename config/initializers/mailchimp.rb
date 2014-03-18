if ActiveRecord::Base.connection.tables.include?(::Configuration.table_name)
  MAILCHIMP_API_KEY = Configuration[:mailchimp_api_key]
end
