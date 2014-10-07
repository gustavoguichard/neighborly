module Webhook
  class Event < ActiveRecord::Base
    validates :serialized_record, :kind, presence: true
  end
end
