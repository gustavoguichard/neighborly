# Disable sidekiq
require 'sidekiq/testing'
Sidekiq::Testing.fake!

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

  categories = %w{facebook twitter linkedin}
  categories.each do |name|
    OauthProvider.create! name: name, path: name, secret: 'SOMETHING', key: 'SOMETHING'
  end

puts '---------------------------------------------'
puts 'Done!'


puts 'Creating Category entries...'

  categories = %w{Transit Bicycling Technology Entertainment Sports Recreation Schools Streetscapes Environment Restoration Event Mobility}
  categories.each do |c|
    Category.create! name: c
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
  u = User.new email: Configuration[:email_contact].dup, password: SecureRandom.hex(4)
  u.skip_confirmation!
  u.confirm!
  u.save

  # User to receive new projects on draft notifications
  u = User.new email: Configuration[:email_projects].dup, password: SecureRandom.hex(4)
  u.skip_confirmation!
  u.confirm!
  u.save

  # User to receive order notifications
  u = User.new email: Configuration[:email_new_order].dup, password: SecureRandom.hex(4), locale: :en
  u.skip_confirmation!
  u.confirm!
  u.save

puts '---------------------------------------------'
puts 'Done!'
