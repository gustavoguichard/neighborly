CatarseMonkeymail.configure do |config|
  config.api_key = ::Configuration[:mailchimp_api_key]
  config.list_id = ::Configuration[:mailchimp_list_id]
end
