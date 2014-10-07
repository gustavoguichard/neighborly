module Webhook
  class EventSenderWorker
    include Sidekiq::Worker
    sidekiq_options retry: 2

    def perform(event_id)
      EventSender.new(event_id).send
    end
  end
end
