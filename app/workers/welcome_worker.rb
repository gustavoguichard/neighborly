class WelcomeWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5

  def perform(user_id)
    resource = User.find(user_id)

    Notification.notify_once(:new_user_registration, resource, {user_id: resource.id})
    resource.update_attribute(:newsletter, true)
  rescue ActiveRecord::RecordNotFound
    raise "User #{user_id} not found.. sending to retry queue"
  end
end
