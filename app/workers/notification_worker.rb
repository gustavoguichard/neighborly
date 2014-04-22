class NotificationWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5

  def perform(notification_id)
    resource = Notification.find(notification_id)

    if resource
      NotificationsMailer.notify(resource).deliver
      resource.update_attributes dismissed: true
    end
  rescue ActiveRecord::RecordNotFound
    raise "Notification #{notification_id} not found.. sending to retry queue"
  end
end
