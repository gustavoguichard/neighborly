require 'ffaker'

# Disable sidekiq
require 'sidekiq/testing'
Sidekiq::Testing.fake!

def lorem_pixel_url(size = '100/100', type = 'city')
  "http://jpg-lorem-pixel.herokuapp.com/#{type}/#{size}/image.jpg"
end

def generate_user
  u = User.new name: Faker::Name.name,
               email: Faker::Internet.email,
               remote_uploaded_image_url: lorem_pixel_url('150/150', 'people')
  u.skip_confirmation!
  u.save
  u
end

def generate_project(fields = {})
   p = Project.create!({ user: User.where(email: 'org@org.com').first,
                     category: Category.order('RANDOM()').limit(1).first,
                     name: Faker::Lorem.sentence(2),
                     about: Faker::Lorem.paragraph(10),
                     headline: Faker::Lorem.sentence,
                     goal: [40000, 73000, 1000, 50000, 100000].shuffle.first,
                     online_date: Time.now,
                     online_days: [50, 90, 43, 87, 34].shuffle.first,
                     how_know: Faker::Lorem.sentence,
                     video_url: 'http://vimeo.com/79833901',
                     home_page: true,
                     address: "#{Faker::Address.city}, #{Faker::AddressUS.state_abbr}",
                     remote_uploaded_image_url: lorem_pixel_url('500/400', 'city'),
                     remote_hero_image_url: lorem_pixel_url('1280/600', 'city')
    }.merge!(fields))

   [3, 5, 7].shuffle.first.times { Reward.create! project: p, minimum_value: [10, 20, 30, 40, 50, 60, 70].shuffle.first, title: Faker::Lorem.sentence, description: Faker::Lorem.paragraph(2) }
   p
end

def generate_contribution(project, fields: {}, reward: true)
  r = project.rewards.order('RANDOM()').limit(1).first if reward
  c = Contribution.create!( { project: project, user: generate_user, reward: r, value: r.minimum_value}.merge!(fields) )
  c.update_column(:state, 'confirmed')
  c
end

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
    catarse_fee: 0.05,
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
               password: 'password',
               remote_uploaded_image_url: lorem_pixel_url('150/150', 'people')
  u.admin = true
  u.skip_confirmation!
  u.confirm!
  u.save

puts '---------------------------------------------'
puts 'Done!'

puts 'Creating Test user...'

  User.new admin: false,
           name: 'Test',
           email: 'test@test.com',
           password: 'password',
           remote_uploaded_image_url: lorem_pixel_url('150/150', 'people')
  u.admin = true
  u.skip_confirmation!
  u.confirm!
  u.save

puts '---------------------------------------------'
puts 'Done!'

puts 'Creating Organization user...'

  u = User.new email: 'org@org.com',
               password: 'password',
               profile_type: 'organization',
               organization_attributes: { name: 'Organization Name', remote_image_url: lorem_pixel_url('300/150', 'bussines') }
  u.admin = true
  u.confirm!
  u.save

puts '---------------------------------------------'
puts 'Done!'

puts 'Creating Channel user...'

  u = User.new name: 'Channel',
               email: 'channel@channel.com',
               password: 'password',
               profile_type: 'channel'
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

puts 'Creating channel...'

  c = Channel.create! user: User.where(email: 'channel@channel.com').first,
                      name: 'Channel Name',
                      permalink: 'channel',
                      description: Faker::Lorem.paragraph,
                      remote_image_url: lorem_pixel_url('600/300', 'bussines')
  c.push_to_online!

puts '---------------------------------------------'
puts 'Done!'

puts 'Creating channel projects...... It can take a while... You can go and get a coffee now!'

  3.times do
    p = generate_project(channels: [Channel.order('RANDOM()').limit(1).first])
    p.approve!
  end

  channel_project = Project.first
  channel_project.push_to_draft!
  channel_project.reject!
  channel_project.push_to_draft!
  channel_project.approve!
  channel_project.update_column(:recommended, true)

puts '---------------------------------------------'
puts 'Done!'


puts 'Creating successfull projects...... It can take a while...'

  6.times do
    p = generate_project(state: 'online', goal: 1000, online_days: [30, 45, 12].shuffle.first)
    [4, 7, 15, 30].shuffle.first.times { generate_contribution(p) }
    p.update_attributes( { state: :successful, online_date: (Time.now - 50.days) })
  end

puts '---------------------------------------------'
puts 'Done!'


puts 'Creating failed projects...... It can take a while...'

  2.times do
    p = generate_project(state: 'online', goal: 100000, campaign_type: 'all_or_none')
    [4, 7, 15, 30].shuffle.first.times { generate_contribution(p) }
    p.update_column(:state, :failed)
  end

puts '---------------------------------------------'
puts 'Done!'

puts 'Creating online projects all_or_none...... It can take a while...'

  2.times do
    p = generate_project(state: 'online', campaign_type: 'all_or_none')
    [4, 7].shuffle.first.times { generate_contribution(p) }
  end

puts '---------------------------------------------'
puts 'Done!'



puts 'Creating online projects...... It can take a while...'

  5.times do
    p = generate_project(state: 'online')
    [4, 3, 5, 23].shuffle.first.times { generate_contribution(p) }
  end
  p = Project.last
  p.update_column(:featured, true)

puts '---------------------------------------------'
puts 'Done!'

puts 'Creating soon projects ...... It can take a while...'

  4.times do
    generate_project(state: 'soon')
  end

puts '---------------------------------------------'
puts 'Done!'

puts 'Creating ending soon projects ...... It can take a while...'

  2.times do
    p = generate_project(state: 'online', online_days: 14)
    p.update_column(:online_date, Time.now - 10.days)
  end

puts '---------------------------------------------'
puts 'Done!'
