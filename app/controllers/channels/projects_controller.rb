class Channels::ProjectsController < ProjectsController
  after_action :associate_with_channel, only: :create

  private

  def associate_with_channel
    resource.channels << channel
    resource.save
  end
end
