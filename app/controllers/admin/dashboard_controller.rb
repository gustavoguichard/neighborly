class Admin::DashboardController < Admin::BaseController
  inherit_resources
  defaults  resource_class: Statistics
  actions :index
end
