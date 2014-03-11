###
# Application's tasks.
# These task are required by the application.
# They are used on Heroku Scheduler.
###

desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  Project.to_finish.each do |project|
    CampaignFinisherWorker.perform_async(project.id)
  end
end

desc "This tasks should be executed 1x per day"
task notify_project_owner_about_new_confirmed_contributions: :environment do
  Project.with_contributions_confirmed_today.each do |project|
    Notification.notify_once(
      :project_owner_contribution_confirmed,
      project.user,
      {user_id: project.user.id, project_id: project.id, 'notifications.created_at' => Date.today},
      {project: project}
    )
  end
end

desc "Move to deleted state all contributions that are in pending a lot of time"
task :move_pending_contributions_to_trash => [:environment] do
  Contribution.where("state in('pending') and created_at + interval '6 days' < current_timestamp").update_all({state: 'deleted'})
end

desc "Cancel all waiting_confirmation contributions that is passed 4 weekdays"
task :cancel_expired_waiting_confirmation_contributions => :environment do
  Contribution.can_cancel.update_all(state: 'canceled')
end
