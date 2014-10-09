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
        record: event.serialized_record.to_json,
        type: event.kind,
        authentication_key: generate_authentication_key
      }
    end

    def generate_authentication_key
      OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA256.new,
                              Configuration[:webhook_secret_key],
                              event.serialized_record.to_s)
    end

    def webhook_url
      URI.parse(Configuration[:neighborly_webhook_url])
    end
  end
end
