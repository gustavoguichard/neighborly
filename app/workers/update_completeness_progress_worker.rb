class UpdateCompletenessProgressWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5

  def perform(user_id)
    user = User.find(user_id)
    user.update_completeness_progress!
  end
end
