class Channels::ProfilesController < Channels::BaseController
  add_to_menu 'channels.admin.profile_menu', :edit_channels_profile_path
  inherit_resources

  actions :show, :edit, :update
  custom_actions resource: [:how_it_works]

  before_action only: [:edit, :update] do
    authorize!(params[:action], resource)
  end

  def show
    @projects = resource.projects.visible
  end

  def resource
    @profile ||= channel
  end
end
