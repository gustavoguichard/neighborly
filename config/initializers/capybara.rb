if Rails.env.development? || Rails.env.test?
  require 'capybara/rails'
  Capybara.javascript_driver = :webkit
end

