class NotificationsMailer < ActionMailer::Base
  layout 'email'

  def notify(notification)
    @notification = notification
    address = Mail::Address.new @notification.origin_email
    address.display_name = @notification.origin_name
    subject = render_to_string(template: "notifications_mailer/subjects/#{@notification.template_name}")

    params = {
      from: address.format,
      to: @notification.user.email,
      subject: subject,
      template_name: @notification.template_name
    }

    params.merge!({ bcc: @notification.bcc }) if @notification.bcc.present?
    m = mail(params)
    m
  end
end
