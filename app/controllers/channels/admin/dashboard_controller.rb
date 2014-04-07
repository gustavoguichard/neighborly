module Channels::Admin
  class DashboardController < BaseController
    def index
      @total_projects = channel.projects.size
      @total_subscribers = channel.subscribers.count
    end
  end
end
