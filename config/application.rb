require File.expand_path('../boot', __FILE__)
require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require *Rails.groups(assets: %w(development test))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Catarse
  class Application < Rails::Application
    config.to_prepare do
      Devise::Mailer.layout "email" # email.haml or email.erb
    end

    config.paths['app/views'].unshift("#{Rails.root}/app/views/custom")

    config.active_record.schema_format = :sql

    # Since Rails 3.1, all folders inside app/ will be loaded automatically
    config.autoload_paths += %W(#{config.root}/lib #{config.root}/lib/**)

    config.i18n.load_path += Dir[Rails.root.join('app', 'locales', '**', '*.{rb,yml}').to_s]
    config.i18n.load_path += Dir[Rails.root.join('app', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :en

    # Default encoding for the server
    config.encoding = "utf-8"

    config.filter_parameters += [:password, :password_confirmation]
    config.time_zone = 'Central Time (US & Canada)'
    config.active_record.default_timezone = :local

    # Do not generate specs for views and requests. Also, do not generate assets.
    config.generators do |g|
      g.javascripts false
      g.stylesheets false
      g.helper false
      g.template_engine :slim
      g.test_framework :rspec,
        view_specs: false,
        helper_specs: false,
        fixture: false
    end

    config.active_record.observers = [
      :backer_observer, :user_observer,
      :update_observer, :project_observer, :payment_notification_observer
    ]

    # Enable the asset pipeline
    config.assets.enabled = true

    # Don't initialize the app when compiling
    config.assets.initialize_on_precompile = false

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'


    # TODO: remove
    config.active_record.whitelist_attributes = false

    config.middleware.use "WwwDitcher" if Rails.env.production?

    config.to_prepare do
      Devise::SessionsController.layout 'devise'
      Devise::RegistrationsController.layout proc{ |controller| user_signed_in? ? 'application' : 'devise' }
      Devise::ConfirmationsController.layout 'devise'
      Devise::UnlocksController.layout 'devise'
      Devise::PasswordsController.layout 'devise'
    end
  end
end
