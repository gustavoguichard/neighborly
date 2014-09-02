class NotificationWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5

  def perform(notification_id)
    notification = Notification.find(notification_id)

    NotificationsMailer.notify(notification).deliver
    notification.update_attributes(dismissed: true)
  end
end
