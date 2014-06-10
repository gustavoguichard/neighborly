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
                     address_city: Faker::Address.city,
                     address_state: Faker::AddressUS.state_abbr,
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

puts 'Setting image for admin user...'

  u = User.find_by(admin: true)
  u.remote_uploaded_image_url = lorem_pixel_url('150/150', 'people')
  u.save

puts '---------------------------------------------'
puts 'Done!'

puts 'Creating Test user...'

  u = User.new admin: false,
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
    p.launch!
  end

  channel_project = Project.first
  channel_project.push_to_draft!
  channel_project.reject!
  channel_project.push_to_draft!
  channel_project.launch!
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

