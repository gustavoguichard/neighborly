module Webhook
  class EventRecordSerializer < ActiveModel::Serializer
    delegate :attributes, to: :object
  end

  class EventRegister
    def initialize(record, created: false)
      @record, @created = record, created
      event = Event.create(serialized_record: serialized_record, kind: type)
      EventSenderWorker.perform_async(event.id)
    end

    def serialized_record
      EventRecordSerializer.new(@record, root: false).as_json
    end

    def type
      action = @created ? 'created' : 'updated'

      [@record.class.model_name.i18n_key, action].join('.')
    end
  end
end
