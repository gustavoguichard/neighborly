class UserObserver < ActiveRecord::Observer
  observe :user

  def before_validation(user)
    user.password = SecureRandom.hex(4) unless user.password || user.persisted?
  end

  def after_create(user)
    return if user.email =~ /change-your-email\+[0-9]+@neighbor\.ly/
    Notification.notify_once(:new_user_registration, user, {user_id: user.id})
    user.update_attribute(:newsletter, true)
  end

  def before_save(user)
    user.fix_twitter_user
    user.fix_facebook_link
  end
end
