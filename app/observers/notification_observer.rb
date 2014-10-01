class NotificationObserver < ActiveRecord::Observer
  def after_commit(notification)
    if just_created?(notification)
      deliver(notification)
    end
  end

  private

  def deliver(notification)
    unless notification.dismissed || disabled?(notification)
      NotificationWorker.perform_async(notification.id)
    end
  end

  def just_created?(notification)
    !!notification.send(:transaction_record_state, :new_record)
  end

  # Disabled during the first days of Bonds MVP release
  def disabled?(notification)
    %w(
      new_draft_project
      project_approved
      project_in_wainting_funds
      project_received
      project_rejected
      project_visible
    ).include? notification.template_name
  end
end
