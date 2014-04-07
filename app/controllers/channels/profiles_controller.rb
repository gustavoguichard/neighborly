class Channels::ProfilesController < Channels::BaseController
  inherit_resources

  actions :show
  custom_actions resource: [:how_it_works]

  before_action only: [:edit, :update] do
    authorize!(params[:action], resource)
  end

  def show
    @projects = resource.projects.visible
  end

  def resource
    @profile ||= Channel.find_by_permalink!(request.subdomain.to_s)
  end
end
