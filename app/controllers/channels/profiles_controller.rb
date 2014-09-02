class Channels::ProfilesController < Channels::BaseController
  def show
    @channel = Channel.find_by_permalink!(request.subdomain.to_s)
    @active_projects = @channel.projects.active
    @other_projects = @channel.projects.visible.without_state('online')
  end
end
