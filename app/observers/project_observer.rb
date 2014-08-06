class ProjectObserver < ActiveRecord::Observer
  def after_save(project)
    if project.video_url.present? && project.video_url_changed?
      ProjectDownloaderWorker.perform_async(project.id)
    end
  end

  def after_create(project)
    deliver_default_notification_for(project, :project_received)
    notify_new_draft_project(project)
  end

  def from_online_to_waiting_funds(project)
    project.notify_owner(:project_in_wainting_funds)
  end

  def from_waiting_funds_to_successful(project)
    project.notify_owner(:project_success)

    notify_admin_that_project_reached_deadline(project)
    notify_users(project)
  end

  def notify_admin_that_project_reached_deadline(project)
    if (user = User.where(email: ::Configuration[:email_payments]).first)
      Notification.notify_once(
        :adm_project_deadline,
        user,
        {project_id: project.id},
        project: project,
        origin_email: Configuration[:email_system],
        project: project
      )
    end
  end

  def from_draft_to_rejected(project)
    deliver_default_notification_for(project, :project_rejected)
  end

  def from_draft_to_online(project)
    deliver_default_notification_for(project, :project_visible)
    notify_users_that_a_new_project_is_online(project)
    project.update_attributes({ online_date: DateTime.now })
  end

  def from_draft_to_soon(project)
    project.notify_owner(:project_approved)
  end

  def from_soon_to_online(project)
    from_draft_to_online(project)
  end

  def from_online_to_failed(project)
    notify_users(project)

    project.contributions.with_state('waiting_confirmation').each do |contribution|
      contribution.notify_owner(:pending_contribution_project_unsuccessful,
                                { },
                                project: project)
    end

    project.notify_owner(:project_unsuccessful, user_id: project.user.id)
  end

  def from_waiting_funds_to_failed(project)
    from_online_to_failed(project)
    notify_admin_that_project_reached_deadline(project)
  end

  private

  def notify_new_draft_project(project)
    if (user = project.new_draft_recipient)
      Notification.notify_once(
        project.notification_type(:new_draft_project),
        user,
        {project_id: project.id, channel_id: project.last_channel.try(:id)},
        {
          project: project,
          channel: project.last_channel,
          origin_email: project.user.email,
          origin_name: project.user.display_name
        }
      )
    end
  end

  def notify_users_that_a_new_project_is_online(project)
    User.where(new_project: true).each do |user|
      Notification.notify_once(:new_project_visible,
        user,
        {project_id: project.id, user_id: user.id},
        project: project)
    end
  end

  def notify_users(project)
    project.contributions.with_state('confirmed').each do |contribution|
      unless contribution.notified_finish
        contribution.notify_owner((project.successful? ? :contribution_project_successful : :contribution_project_unsuccessful),
                                  { },
                                  { project: project })

        contribution.update_attributes({ notified_finish: true })
      end
    end
  end

  def deliver_default_notification_for(project, notification_type)
    project.notify_owner(
      project.notification_type(notification_type),
      { channel_id: project.last_channel.try(:id) },
      {
        channel: project.last_channel,
        origin_email: project.last_channel.try(:user).try(:email) || Configuration[:email_contact],
        origin_name: project.last_channel.try(:name) || Configuration[:company_name]
      }
    )
  end
end
