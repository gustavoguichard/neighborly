class WelcomeWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5

  def perform(user_id)
    user = User.find(user_id)

    Notification.notify_once(:new_user_registration, user, user_id: user.id)
    user.update_attribute(:newsletter, true)
  end
end
