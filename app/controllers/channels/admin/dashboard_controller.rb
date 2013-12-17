class Channels::Admin::DashboardController < Admin::BaseController
  def index
    @total_projects = channel.projects.size
    @total_subscribers = channel.subscribers.count
  end
end
