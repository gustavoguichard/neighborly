class UpdateCompletenessProgressWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5

  def perform(user_id)
    resource = User.find(user_id)
    resource.update_completeness_progress!
  rescue ActiveRecord::RecordNotFound
    raise "User #{user_id} not found.. sending to retry queue"
  end
end
