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

  factory :user do
    confirmed_at { Time.now }
    email        { "sherlock.holmes#{rand}@example.com" }
    password     '123123123'
  end

  factory :user_with_uploaded_image, parent: :user do |f|
    f.uploaded_image File.open("#{Rails.root}/spec/fixtures/image.png")
  end

  factory :category do
    ignore do
      name { "Category ##{rand}" }
    end

    name_en { name }
    name_pt { name }
  end

  factory :project do
    address_city       'Kansas City'
    address_state      'MO'
    credit_type        'general_obligation'
    goal               10000
    headline           'Foo bar'
    home_page          true
    how_know           'Lorem ipsum'
    minimum_investment 500
    name               'Foo bar'
    online_days        30
    permalink          { "#{name.parameterize}-#{SecureRandom.hex}" }
    statement_file_url 'http://example.com/statement.pdf'
    sale_date          { -1.day.from_now }
    state              'online'
    summary            'Foo bar'
    video_url          'http://vimeo.com/17298435'
    category
    user

    trait :with_rewards do
      after(:create) do |instance|
        create :reward, project: instance
      end
    end
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

  factory :reward do
    happens_at { 3.years.from_now }
    project
  end

  factory :activity do |f|
    project
    user
    title 'Foo Bar'
    summary 'Foo Bar Summary'
    happened_at { Time.now }
  end

  factory :contribution do |f|
    f.association :project, factory: :project
    f.association :user, factory: :user
    f.confirmed_at Time.now
    f.value 10.00
    f.state 'confirmed'
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

    factory :channel_with_external_application do
      application_url 'https://example.com/application.pdf'
    end
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

  factory :contact do
    first_name 'First'
    last_name 'Last'
    email 'some@email.com'
    organization_name 'Test'
  end

  factory :image do |f|
    f.association :user
    f.file File.open("#{Rails.root}/spec/fixtures/image.png")
  end
end
