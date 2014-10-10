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
