FactoryGirl.define do
  sequence :name do |n|
    "Foo bar #{n}"
  end

  sequence :email do |n|
    "person#{n}@example.com"
  end

  sequence :uid do |n|
    "#{n}"
  end

  sequence :permalink do |n|
    "foo_page_#{n}"
  end

  factory :project_faq do |f|
    f.title "Foo bar"
    f.answer "Bar foo"
    f.association :project
  end

  factory :project_document do |f|
    f.name 'name'
    f.document "foo.png"
    f.association :project
  end

  factory :user do |f|
    f.name "Foo bar"
    f.password "123456"
    f.email { generate(:email) }
    f.bio "This is Foo bar's biography."
    f.confirmed_at { Time.now }
  end

  factory :category do |f|
    f.name_pt { generate(:name) }
    f.name_en { generate(:name) }
  end

  factory :project do |f|
    f.name "Foo bar"
    f.campaign_type { :flexible }
    f.permalink { generate(:permalink) }
    f.association :user, factory: :user
    f.association :category, factory: :category
    f.about "Foo bar"
    f.headline "Foo bar"
    f.goal 10000
    f.online_date Time.now
    f.online_days 5
    f.how_know 'Lorem ipsum'
    f.more_links 'Ipsum dolor'
    f.video_url 'http://vimeo.com/17298435'
    f.state 'online'
    f.home_page true
    f.address_city 'Kansas City'
    f.address_state 'MO'
  end

  factory :unsubscribe do |f|
    f.association :user, factory: :user
    f.association :project, factory: :project
  end

  factory :notification do |f|
    f.association :user, factory: :user
    f.association :contribution, factory: :contribution
    f.association :project, factory: :project
    f.template_name 'project_success'
    f.origin_name 'Foo Bar'
    f.origin_email 'foo@bar.com'
    f.locale 'en'
  end

  factory :reward do |f|
    f.association :project, factory: :project
    f.title "Awesome Foo Bar"
    f.minimum_value 10.00
    f.description "Foo bar"
    f.days_to_delivery 10
  end

  factory :contribution do |f|
    f.association :project, factory: :project
    f.association :user, factory: :user
    f.confirmed_at Time.now
    f.value 10.00
    f.state 'confirmed'
    f.credits false
  end

  factory :payment_notification do |f|
    f.association :contribution, factory: :contribution
    f.extra_data {}
  end

  factory :authorization do |f|
    f.association :oauth_provider
    f.association :user
    f.uid 'Foo'
  end

  factory :oauth_provider do |f|
    f.name 'facebook'
    f.strategy 'GitHub'
    f.path 'github'
    f.key 'test_key'
    f.secret 'test_secret'
  end

  factory :configuration do |f|
    f.name 'Foo'
    f.value 'Bar'
  end

  factory :institutional_video do |f|
    f.title "My title"
    f.description "Some Description"
    f.video_url "http://vimeo.com/35492726"
    f.visible false
  end

  factory :update do |f|
    f.association :project, factory: :project
    f.association :user, factory: :user
    f.title "My title"
    f.comment "This is a comment"
    f.comment_html "<p>This is a comment</p>"
  end

  factory :channel do
    user { create(:user, profile_type: 'channel') }
    name "Test"
    description "Lorem Ipsum"
    sequence(:permalink) { |n| "#{n}-test-page" }
  end

  factory :channels_subscriber do |f|
    f.association :user
    f.association :channel
  end

  factory :state do
    name "RJ"
    acronym "RJ"
  end

  factory :press_asset do
    title 'Lorem'
    url 'http://lorem.com'
    image File.open("#{Rails.root}/spec/fixtures/image.png")
  end

  factory :tag do
    name 'bike'
  end

  factory :organization do |f|
    f.association :user
    f.name 'Organization name'
    f.image File.open("#{Rails.root}/spec/fixtures/image.png")
  end

  factory :users_oauth_provider, class: 'UsersOauthProviders' do
    oauth_provider 1
    user_id 1
    uid "MyText"
  end

  factory :company_contact do
    first_name 'First'
    last_name 'Last'
    email 'some@email.com'
    company_name 'Test'
  end
end

