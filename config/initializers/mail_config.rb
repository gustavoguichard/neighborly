begin
  if Rails.env.production?
    # TODO: ADD BACK - REMOVED FOR MIGRATION
    #ActionMailer::Base.smtp_settings = {
    #address: 'smtp.mandrillapp.com',
    #port: '587',
    #authentication: :plain,
    #user_name: Configuration[:mandrill_user_name],
    #password: Configuration[:mandrill],
    #domain: 'heroku.com'
    #}
    #ActionMailer::Base.delivery_method = :smtp
  end
rescue
  nil
end
