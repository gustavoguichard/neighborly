class Admin::DashboardController < Admin::BaseController
  inherit_resources
  defaults  resource_class: Statistics
  menu I18n.t("admin.dashboard.index.menu") => :admin_dashboard_path
  actions :index
end
