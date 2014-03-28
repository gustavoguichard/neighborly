# Disable sidekiq
require 'sidekiq/testing'
Sidekiq::Testing.fake!

puts 'Creating Configuration entries...'

  {
    company_name: 'Neighbor.ly',
    host: 'localhost',
    base_url: 'http://localhost',
    blog_url: 'http://blog.neighbor.ly',
    base_domain: 'localhost',
    email_contact: 'howdy@neighbor.ly',
    email_payments: 'books@neighbor.ly',
    email_system: 'no-reply@neighbor.ly',
    email_no_reply: 'no-reply@neighbor.ly',
    facebook_url: 'http://www.facebook.com/NEIGHBORdotLY',
    facebook_app_id: 255971384512404,
    twitter_username: 'Neighborly',
    platform_fee: 0.05,
    support_forum: 'http://neighborly.uservoice.com/',
    project_finish_time: '02:59:59',
    secret_token: SecureRandom.hex(64),
    secret_key_base: SecureRandom.hex(64),
    currency_charge: 'USD',
    google_analytics_id: 'SOMETHING',
    email_projects: 'ideas@neighbor.ly',
    timezone: 'US/Central',
    devise_secret_key: SecureRandom.hex(64),
    balanced_api_key_secret: 'YOUR_API_KEY_SECRET_HERE',
    balanced_marketplace_id: 'YOUR_MARKETPLACE_ID_HERE'
    #secure_review_host: nil,
    #uservoice_key: nil,
    #mailchimp_api_key: nil,
    #mailchimp_list_id: nil,
    #mailchimp_url: nil,
    #mandrill_user_name: nil,
    #mandrill: nil,
    #aws_bucket: nil,
    #aws_access_key: nil,
    #aws_secret_key: nil,
    #paypal_username: nil,
    #paypal_password: nil,
    #paypal_signature: nil,
    #stripe_api_key: nil,
    #stripe_public_key: nil,
    #authorizenet_login_id: nil,
    #authorizenet_transaction_key: nil
  }.each do |name, value|
     Configuration[name] = value
  end

puts '---------------------------------------------'
puts 'Done!'

puts 'Creating State entries...'

  [[name: 'Alabama', acronym: 'AL'],
  [name: 'Alaska', acronym: 'AK'],
  [name: 'Arizona', acronym: 'AZ'],
  [name: 'Arkansas', acronym: 'AR'],
  [name: 'California', acronym: 'CA'],
  [name: 'Colorado', acronym: 'CO'],
  [name: 'Connecticut', acronym: 'CT'],
  [name: 'Delaware', acronym: 'DE'],
  [name: 'Florida', acronym: 'FL'],
  [name: 'Georgia', acronym: 'GA'],
  [name: 'Hawaii', acronym: 'HI'],
  [name: 'Idaho', acronym: 'ID'],
  [name: 'Illinois', acronym: 'IL'],
  [name: 'Indiana', acronym: 'IN'],
  [name: 'Iowa', acronym: 'IA'],
  [name: 'Kansas', acronym: 'KS'],
  [name: 'Kentucky', acronym: 'KY'],
  [name: 'Louisiana', acronym: 'LA'],
  [name: 'Maine', acronym: 'ME'],
  [name: 'Maryland', acronym: 'MD'],
  [name: 'Massachusetts', acronym: 'MA'],
  [name: 'Michigan', acronym: 'MI'],
  [name: 'Minnesota', acronym: 'MN'],
  [name: 'Mississippi', acronym: 'MS'],
  [name: 'Missouri', acronym: 'MO'],
  [name: 'Montana', acronym: 'MT'],
  [name: 'Nebraska', acronym: 'NE'],
  [name: 'Nevada', acronym: 'NV'],
  [name: 'New Hampshire', acronym: 'NH'],
  [name: 'New Jersey', acronym: 'NJ'],
  [name: 'New Mexico', acronym: 'NM'],
  [name: 'New York', acronym: 'NY'],
  [name: 'North Carolina', acronym: 'NC'],
  [name: 'North Dakota', acronym: 'ND'],
  [name: 'Ohio', acronym: 'OH'],
  [name: 'Oklahoma', acronym: 'OK'],
  [name: 'Oregon', acronym: 'OR'],
  [name: 'Pennsylvania', acronym: 'PA'],
  [name: 'Rhode Island', acronym: 'RI'],
  [name: 'South Carolina', acronym: 'SC'],
  [name: 'South Dakota', acronym: 'SD'],
  [name: 'Tennessee', acronym: 'TN'],
  [name: 'Texas', acronym: 'TX'],
  [name: 'Utah', acronym: 'UT'],
  [name: 'Vermont', acronym: 'VT'],
  [name: 'Virginia', acronym: 'VA'],
  [name: 'Washington', acronym: 'WA'],
  [name: 'West Virginia', acronym: 'WV'],
  [name: 'Wisconsin', acronym: 'WI'],
  [name: 'Wyoming', acronym: 'WY'],
  [name: 'Washington', acronym: 'DC']].each do |item|
    State.create! item
  end

puts '---------------------------------------------'
puts 'Done!'

puts 'Creating OauthProvider entries...'

  categories = %w{facebook twitter google_oauth2 linkedin}
  categories.each do |name|
    OauthProvider.create! name: name, path: name, secret: 'SOMETHING', key: 'SOMETHING'
  end

puts '---------------------------------------------'
puts 'Done!'


puts 'Creating Category entries...'

  categories = %w{Transit Bicycling Technology Entertainment Sports Recreation Schools Streetscapes Environment Restoration Event Mobility}
  categories.each do |c|
    Category.create! name_pt: c, name_en: c
  end

puts '---------------------------------------------'
puts 'Done!'

puts 'Creating Admin user...'
  u = User.new name: 'Admin',
               email: 'admin@admin.com',
               password: 'password'
  u.admin = true
  u.skip_confirmation!
  u.confirm!
  u.save

puts '---------------------------------------------'
puts 'Done!'

puts 'Creating system users...'

  # User to receive company contact notifications
  u = User.new email: Configuration[:email_contact], password: SecureRandom.hex(4)
  u.skip_confirmation!
  u.confirm!
  u.save

  # User to receive new projects on draft notifications
  u = User.new email: Configuration[:email_projects], password: SecureRandom.hex(4)
  u.skip_confirmation!
  u.confirm!
  u.save

puts '---------------------------------------------'
puts 'Done!'
