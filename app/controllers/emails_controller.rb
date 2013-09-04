class EmailsController < ApplicationController
  def index
    @notifications = []

    NotificationType.all.each do |type|
      notification = Notification.where(notification_type: type).first
      @notifications << notification if notification
    end
  end

  def show
    @notification = Notification.find params[:id]
    @header = I18n.t("notifications.#{@notification.notification_type.name}.header", @notification.mail_params)
    message = OpenStruct.new
    message.subject = I18n.t("notifications.#{@notification.notification_type.name}.subject", @notification.mail_params)
    render "notifications_mailer/#{@notification.notification_type.name}", layout: @notification.notification_type.layout, locals: { message: message }
  end
end
