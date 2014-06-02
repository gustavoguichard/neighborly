if ActiveRecord::Base.connection.tables.include?(::Configuration.table_name)
  CatarseMonkeymail.configure do |config|
    config.api_key = ::Configuration[:mailchimp_api_key]
    config.list_id = ::Configuration[:mailchimp_list_id]
  end
end
