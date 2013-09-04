class NotificationObserver < ActiveRecord::Observer
  observe :notification

  def after_create(notification)
    # TODO: ADD BACK - REMOVED FOR MIGRATION
    # TODO: REMOVE FOR MIGRATION
    notification.send_email
  end
end
