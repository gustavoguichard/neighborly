class Admin::DashboardController < Admin::BaseController
  inherit_resources
  defaults  resource_class: Statistics
  menu I18n.t("admin.dashboard.index.menu") => Rails.application.routes.url_helpers.admin_dashboard_path
  actions :index
end

