module Webhook
  class EventSender
    attr_accessor :event

    def initialize(event_id)
      @event = Event.find(event_id)
    end

    def send_request
      Net::HTTP.post_form(webhook_url, request_params)
    end

    def request_params
      {
        record: event.serialized_record,
        type: event.kind,
        authentication_key: authentication_key
      }
    end

    def authentication_key
      # to be implemented
    end

    def webhook_url
      URI.parse(Configuration[:neighborly_webhook_url])
    end
  end
end
