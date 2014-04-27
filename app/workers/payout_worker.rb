class PayoutWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(project_id, requestor_id)
    Payout.complete(project_id, requestor_id)
  end
end
