class WelcomeWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5

  def perform user_id
    resource = User.find user_id
    # We don't want to raise exceptions in case our user does not exist in the database
    if resource
      Notification.notify_once(:new_user_registration, resource, {user_id: resource.id})
      resource.update_attribute(:newsletter, true)
    else
      raise "Notification #{notification_id} not found.. sending to retry queue"
    end
  end
end
