module Channels::Admin
  class Reports::SubscriberReportsController < BaseController
    inherit_resources
    responders :csv
    respond_to :csv
    actions :index

    private
    def end_of_association_chain
      SubscriberReport.where(channel_id: channel.id)
    end
  end
end
