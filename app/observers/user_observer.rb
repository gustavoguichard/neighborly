class UserObserver < ActiveRecord::Observer
  def before_validation(user)
    user.password = SecureRandom.hex(4) unless user.password || user.persisted?
  end

  def after_commit(user)
    #calculate_completeness(user)

    if just_confirmed_account?(user)
      welcome_user(user)
    end

    Webhook::EventRegister.new(user, created: just_created?(user))
  end

  def before_create(user)
    user.referral_code = SecureRandom.urlsafe_base64
  end

  private

  def calculate_completeness(user)
    if user.completeness_progress.to_i < 100
      UpdateCompletenessProgressWorker.perform_async(user.id)
    end
  end

  def welcome_user(user)
    unless user.email =~ /change-your-email\+[0-9]+@neighbor\.ly/
      WelcomeWorker.perform_async(user.id)
    end
  end

  def just_created?(user)
    !!user.send(:transaction_record_state, :new_record)
  end

  def just_confirmed_account?(user)
    user.confirmed_at_changed?
  end
end
