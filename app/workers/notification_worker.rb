class NotificationWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5

  def perform(notification_id)
    resource = Notification.find(notification_id)

    NotificationsMailer.notify(resource).deliver
    resource.update_attributes dismissed: true
  rescue ActiveRecord::RecordNotFound
    raise "Notification #{notification_id} not found.. sending to retry queue"
  end
end
