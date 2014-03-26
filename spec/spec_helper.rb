# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require 'coveralls'
Coveralls.wear!('rails')

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'sidekiq/testing'
require 'fakeweb'
require 'pundit/rspec'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

def fixture_path(basename)
  "spec/fixtures/#{basename}"
end


# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.include ActionView::Helpers::TextHelper
  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  #config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.before(:suite) do
    ActiveRecord::Base.connection.execute "SET client_min_messages TO warning;"
    ActiveRecord::Base.connection.execute "SET timezone TO 'utc';"
    DatabaseCleaner.clean_with :truncation
    I18n.locale = :en
    I18n.default_locale = :en

    Geocoder.configure(lookup: :test)
    Geocoder::Lookup::Test.set_default_stub(
      [
        {
          'latitude'     => 40.7143528,
          'longitude'    => -74.0059731,
          'address'      => 'New York, NY, USA',
          'state'        => 'New York',
          'state_code'   => 'NY',
          'country'      => 'United States',
          'country_code' => 'US'
        }
      ]
    )

    FakeWeb.register_uri(:get, "http://vimeo.com/api/v2/video/17298435.json", response: fixture_path('vimeo_default_json_request.txt'))
    FakeWeb.register_uri(:get, "http://vimeo.com/17298435", response: fixture_path('vimeo_default_request.txt'))
    FakeWeb.register_uri(:get, "http://www.youtube.com/watch?v=Brw7bzU_t4c", response: fixture_path("youtube_request.txt"))
    #FakeWeb.register_uri(:get, %r|https://api\.mailchimp\.com/|, body: 'Something here', status: ["200", "OK"])
  end

  config.before(:each) do
    if example.metadata[:type] == :feature
      DatabaseCleaner.strategy = :truncation
    else
      DatabaseCleaner.strategy = :transaction
    end
    DatabaseCleaner.start
    ActionMailer::Base.deliveries.clear
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  [:controller, :feature].each do |spec_type|
    config.before(:each, type: spec_type) do
      [:render_facebook_sdk, :render_facebook_like, :render_twitter, :display_uservoice_sso].each do |method|
        ApplicationController.any_instance.stub(method)
      end
    end
  end

  # Stubs and configuration
  config.before(:each) do
    result = OpenStruct.new 'latitude'     => 40.7143528,
                            'longitude'    => -74.0059731,
                            'address'      => 'New York, NY, USA',
                            'state'        => 'New York',
                            'state_code'   => 'NY',
                            'country'      => 'United States',
                            'country_code' => 'US'
    Geocoder.stub :search => [Geocoder::Result::Base.stub(:new).and_return(result)]
    Geocoder.stub :coordinates => [result.latitude, result.longitude]

    CatarseMailchimp::API.stub(:subscribe).and_return(true)
    CatarseMailchimp::API.stub(:unsubscribe).and_return(true)
    Project.any_instance.stub(:store_image_url).and_return('http://www.store_image_url.com')
    ProjectObserver.any_instance.stub(:after_create)
    UserObserver.any_instance.stub(:after_create)
    Project.any_instance.stub(:download_video_thumbnail)
    Notification.stub(:notify)
    Notification.stub(:notify_once)
    Configuration[:base_domain] = 'localhost'
    Configuration[:email_contact] = 'foo@bar.com'
    Configuration[:company_name] = 'Foo Bar Company'
    Configuration[:timezone] = 'US/Central'
  end
end
