class PayoutWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(project_id, requestor)
    Payout.complete(project_id, requestor)
  end
end
