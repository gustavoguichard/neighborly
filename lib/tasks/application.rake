###
# Application's tasks.
# These task are required by the application.
# They are used on Heroku Scheduler.
###

desc 'This task is called by the Heroku cron add-on'
task :cron => :environment do
  Project.to_finish.each do |project|
    CampaignFinisherWorker.perform_async(project.id)
  end
end

desc 'Move to deleted state all contributions that are in pending for one hour'
task :move_pending_contributions_to_trash => [:environment] do
  Contribution.where("state in('pending') and created_at + interval '1 hour' <  ?", Time.current).update_all({state: 'deleted'})
end
