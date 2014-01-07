source 'https://rubygems.org'

ruby '2.1.0'

gem 'rails',    '4.0.2'

gem 'protected_attributes', '~> 1.0.5' # When upgrade to strong_parameters, remove this gem.
gem 'rails-observers', '~> 0.1.2'

gem 'sidekiq',  '~> 2.17.0'
gem 'sinatra', '~> 1.4.3', require: false # required by sidekiq web interface mounted on /sidekiq

# Turns every field on a editable one
gem 'best_in_place', github: 'bernat/best_in_place', branch: 'rails-4'

# State machine for attributes on models
gem 'state_machine', require: 'state_machine/core'

# Database and data related
gem 'pg'
gem 'postgres-copy'
gem 'pg_search'

gem 'schema_plus'
gem 'schema_associations'
gem 'chartkick', '1.2.0'

# Payment engines
gem 'catarse_credit_card_net', github: 'luminopolis/catarse_credit_card_net', ref: '7413ebaba40505881e3366b26b4238981d82d67a'
gem 'catarse_echeck_net', github: 'luminopolis/catarse_echeck_net', ref: 'f5c6f32b857c5e651c55d4713d779100c3c10e4f'
gem 'catarse_paypal_express', github: 'luminopolis/catarse_paypal_express', ref: 'd2382b1c7c3cb5f230b901776aa08fe827acce98'
gem "authorize-net", "~> 1.5.2"

# Decorators
gem 'draper'

# Frontend stuff
gem 'slim-rails'
gem 'jquery-rails', '~> 3.0.4'
gem 'browser'

# Static pages
gem 'high_voltage'

# Authentication and Authorization
gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-google-oauth2', '0.2.1'
gem 'omniauth-linkedin'
gem 'omniauth-facebook', '1.5.1'
gem 'devise', '~> 3.1.2'
gem 'ezcrypto'

# See https://github.com/ryanb/cancan/tree/2.0 for help about this
# In resume: this version of cancan allow checking for authorization on specific fields on the model
gem 'cancan', github: 'ryanb/cancan', branch: '2.0', ref: 'f1cebde51a87be149b4970a3287826bb63c0ac0b'

# Email marketing
gem 'catarse_mailchimp', git: 'git://github.com/catarse/catarse_mailchimp', ref: '2ed4f39'

# HTML manipulation and formatting
gem 'formtastic',   '~> 2.2.1' # WILL BE REMOVED
gem 'simple_form', '~> 3.0.0'
gem 'auto_html', github: 'dejan/auto_html'
gem 'kaminari'

# Uploads
gem 'carrierwave', '~> 0.9.0'
gem 'rmagick'
gem 'dropzonejs-rails', '~> 0.4.10'

# Other Tools
gem 'has_permalink'
gem 'to_xls'
gem 'ranked-model'
gem 'inherited_resources',        '~> 1.4.1'
gem 'has_scope', '~> 0.6.0.rc'
gem 'spectator-validates_email',  require: 'validates_email'
gem 'video_info', '~> 2.0.2'
gem 'enumerate_it'
gem 'pludoni-simple_captcha', require: 'simple_captcha', github: 'pludoni/simple-captcha', branch: 'rails-4'
gem 'geocoder'

# Payment
gem 'httpclient',     '>= 2.2.5'

group :production do
  gem 'google-analytics-rails'

  # Gem used to handle image uploading
  gem 'unf'
  gem 'fog', '>= 1.3.1'

  # Workers, forks and all that jazz
  gem 'unicorn'

  # Enabling Gzip on Heroku
  # If you don't use Heroku, please comment the line below.
  gem 'heroku-deflater', '>= 0.4.1'

  # Make heroku serve static assets and loggin with stdout
  #gem 'rails_on_heroku'
  gem 'rails_12factor'

  # Monitoring with the new new relic
  gem 'newrelic_rpm', '3.6.9.171'

  # Using dalli and memcachier have not presented significative performance gains
  # Probably this is due to our pattern of cache usage
  # + the lack of concurrent procs in our deploy
  #gem 'memcachier'
  #gem 'dalli'
end
group :development do
  gem "letter_opener"
  gem 'thin'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'rails-erd'
  # Uncomment only for optimization, should be commented on master branch
  # gem 'rack-mini-profiler'
end

group :test, :development do
  gem 'rspec-rails', '~> 2.14.1'
  gem 'jasmine-rails', '~> 0.4.6'
  gem 'pry'
end

group :test do
  gem 'fakeweb'
  gem 'poltergeist'
  gem 'launchy'
  gem 'database_cleaner'
  gem 'shoulda'
  gem 'factory_girl_rails'
  gem 'capybara',   '~> 2.1.0'
  gem 'coveralls', require: false
  gem 'selenium-webdriver', '~> 2.35.1'
end

gem 'sass-rails', '~> 4.0.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'compass-rails'
gem 'uglifier'
gem 'font-icons-rails', github: 'shorelabs/font-icons-rails', ref: '19da71315862d54f766645444accd4e9f5dab6e7'
gem 'zurb-foundation', '~> 4.3.2'
gem 'turbolinks'
gem 'nprogress-rails'
gem 'pjax_rails'
gem 'initjs', '~> 2.0.0'

# FIXME: Not-anymore-on-development
# Gems that are with 1 or more years on the vacuum
gem 'weekdays'
