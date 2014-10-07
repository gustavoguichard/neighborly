module Webhook
  class EventSender
    attr_accessor :record, :type

    def initialize(event_id)
      event = Event.find(event_id)
      @record, @type = event.serialized_record, event.kind
    end
  end
end
