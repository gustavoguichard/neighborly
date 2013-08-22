class NotificationsMailer < ActionMailer::Base
  def notify(notification)
    @notification = notification
    from_email = (@notification.mail_params && @notification.mail_params.has_key?(:from)) ? @notification.mail_params[:from] : ::Configuration['email_contact']
    address = Mail::Address.new from_email
    address.display_name = (@notification.mail_params && @notification.mail_params.has_key?(:display_name)) ? @notification.mail_params[:display_name] : ::Configuration[:company_name]
    subject = I18n.t("notifications.#{@notification.notification_type.name}.subject", @notification.mail_params)
    @header = I18n.t("notifications.#{@notification.notification_type.name}.header", @notification.mail_params)
    m = mail({
      from: address.format,
      to: @notification.user.email,
      subject: subject
    }) do |format|
      format.html { render @notification.notification_type.name, layout: @notification.notification_type.layout }
    end
    m
  end
end
