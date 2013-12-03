class Channels::Admin::DashboardController < Admin::BaseController
  menu I18n.t("admin.dashboard.index.menu") => :admin_dashboard_path
  def index
    @total_projects = channel.projects.size
    @total_subscribers = channel.subscribers.count
  end
end
