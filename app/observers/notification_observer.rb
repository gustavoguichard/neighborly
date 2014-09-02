class NotificationObserver < ActiveRecord::Observer
  def after_commit(notification)
    if just_created?(notification)
      deliver(notification)
    end
  end

  private

  def deliver(notification)
    unless notification.dismissed
      NotificationWorker.perform_async(notification.id)
    end
  end

  def just_created?(notification)
    !!notification.send(:transaction_record_state, :new_record)
  end
end
