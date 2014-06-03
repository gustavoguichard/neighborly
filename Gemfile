source 'https://rubygems.org'

ruby '2.1.1'

gem 'rails',    '4.1.1'

gem 'rails-observers', '~> 0.1.2'

gem 'sidekiq',  '~> 2.17.0'
gem 'sinatra', '~> 1.4.3', require: false # required by sidekiq web interface mounted on /sidekiq

# Javascript runtime
gem 'therubyracer'

# State machine for attributes on models
gem 'state_machine', require: 'state_machine/core', github: 'josemarluedke/state_machine'

# Database and data related
gem 'pg'
gem 'postgres-copy'
gem 'pg_search'
gem 'schema_plus'

# Payment engines
gem 'neighborly-balanced-creditcard',  github: 'neighborly/neighborly-balanced-creditcard',  branch: :master
gem 'neighborly-balanced-bankaccount', github: 'neighborly/neighborly-balanced-bankaccount', branch: :master
gem 'neighborly-balanced',             github: 'neighborly/neighborly-balanced',             branch: :master

# Neigbhor.ly Engines
gem 'neighborly-admin', github: 'neighborly/neighborly-admin', branch: :master

# Turns every field on a editable one - Admin dependencies
gem 'best_in_place', github: 'bernat/best_in_place', branch: 'rails-4'

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
gem 'pundit', '~> 0.2.3'

# Email marketing
gem 'catarse_monkeymail', '~> 0.1.3'

# HTML manipulation and formatting
gem 'simple_form', '~> 3.0.2'
gem 'auto_html', '~> 1.6.1'
gem 'kaminari'

# Uploads
gem 'carrierwave', '~> 0.9.0'
gem 'rmagick'
gem 'dropzonejs-rails', '~> 0.4.14'

# Other Tools
gem 'has_permalink'
gem 'ranked-model'
gem 'inherited_resources', '~> 1.4.1'
gem 'has_scope', '~> 0.6.0.rc'
gem 'video_info', '~> 2.0.2'
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
  gem 'spring'
  gem 'ffaker'
  gem "letter_opener"
  gem 'thin'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'quiet_assets'
end

group :test, :development do
  gem 'minitest'
  gem 'rspec-rails', '~> 2.14.2'
  gem 'jasmine-rails', '~> 0.4.6'
  gem 'pry'
  gem 'awesome_print'
end

group :test do
  gem 'fakeweb', require: false
  gem 'launchy'
  gem 'database_cleaner'
  gem 'shoulda-matchers'
  gem 'factory_girl_rails'
  gem 'capybara',   '~> 2.2.1'
  gem 'coveralls', require: false
  gem 'selenium-webdriver', '~> 2.39.0'
end

gem 'sass-rails', '~> 4.0.3'
gem 'coffee-rails', '~> 4.0.1'
gem 'compass-rails'
gem 'uglifier'
gem 'font-icons-rails', github: 'josemarluedke/font-icons-rails', branch: 'fix-svgz'
gem 'zurb-foundation', '~> 4.3.2'
gem 'turbolinks', '~> 2.2.2'
gem 'nprogress-rails'
gem 'pjax_rails'
gem 'initjs', '~> 2.1.2'
gem 'remotipart', '~> 1.2.1'

# FIXME: Not-anymore-on-development
# Gems that are with 1 or more years on the vacuum
gem 'weekdays'
