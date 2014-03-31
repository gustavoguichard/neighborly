source 'https://rubygems.org'

ruby '2.1.1'

gem 'rails',    '4.0.3'

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
gem 'chartkick', '1.2.0'

# Payment engines
gem 'neighborly-balanced-creditcard',  github: 'neighborly/neighborly-balanced-creditcard',  branch: :master
gem 'neighborly-balanced-bankaccount', github: 'neighborly/neighborly-balanced-bankaccount', branch: :master
gem 'neighborly-balanced',             github: 'neighborly/neighborly-balanced',             branch: :master

# Decorators
gem 'draper'

# Frontend stuff
gem 'slim-rails'
gem 'jquery-rails', '~> 3.0.4'
gem 'browser'

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
gem 'pundit', '~> 0.2.2'

# Email marketing
gem 'catarse_mailchimp', github: 'catarse/catarse_mailchimp', ref: '2ed4f39'

# HTML manipulation and formatting
gem 'simple_form', '~> 3.0.1'
gem 'auto_html', '~> 1.6.1'
gem 'kaminari'

# Uploads
gem 'carrierwave', '~> 0.9.0'
gem 'rmagick'
gem 'dropzonejs-rails', '~> 0.4.10'

# Other Tools
gem 'has_permalink'
gem 'ranked-model'
gem 'inherited_resources', '~> 1.4.1'
gem 'has_scope', '~> 0.6.0.rc'
gem 'video_info', '~> 2.0.2'
gem 'pludoni-simple_captcha', require: 'simple_captcha', github: 'pludoni/simple-captcha', branch: 'rails-4'
gem 'geocoder'

# Payment
gem 'httpclient', '>= 2.2.5'

group :production do
  gem 'google-analytics-rails'

  # Gem used to handle image uploading
  gem 'unf'
  gem 'fog', '>= 1.20.0'

  # Workers, forks and all that jazz
  gem 'unicorn'

  # Enabling Gzip on Heroku
  # If you don't use Heroku, please comment the line below.
  gem 'heroku-deflater', '>= 0.4.1'

  # Make heroku serve static assets and loggin with stdout
  gem 'rails_12factor'

  # Monitoring with the new new relic
  gem 'newrelic_rpm', '3.6.9.171'
end

group :development do
  gem 'ffaker'
  gem "letter_opener"
  gem 'thin'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'quiet_assets'
end

group :test, :development do
  gem 'rspec-rails', '~> 2.14.1'
  gem 'jasmine-rails', '~> 0.4.6'
  gem 'pry'
  gem 'awesome_print'
end

group :test do
  gem 'fakeweb'
  gem 'launchy'
  gem 'database_cleaner'
  gem 'shoulda'
  gem 'factory_girl_rails'
  gem 'capybara',   '~> 2.2.1'
  gem 'coveralls', require: false
  gem 'selenium-webdriver', '~> 2.39.0'
end

gem 'sass-rails', '~> 4.0.1'
gem 'coffee-rails', '~> 4.0.1'
gem 'compass-rails'
gem 'uglifier'
gem 'font-icons-rails', github: 'shorelabs/font-icons-rails', ref: '19da71315862d54f766645444accd4e9f5dab6e7'
gem 'zurb-foundation', '~> 4.3.2'
gem 'turbolinks', '~> 2.2.1'
gem 'nprogress-rails'
gem 'pjax_rails'
gem 'initjs', '~> 2.1.1'

# FIXME: Not-anymore-on-development
# Gems that are with 1 or more years on the vacuum
gem 'weekdays'
