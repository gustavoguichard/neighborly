module Webhook
  class EventsController < ApplicationController
    skip_before_filter :verify_authenticity_token

    def create
      EventReceiver.new(params).process_request
      render nothing: true
    end
  end
end
