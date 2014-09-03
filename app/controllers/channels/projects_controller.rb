class Channels::ProjectsController < ProjectsController
  before_action :check_application_method, only: %w(new create)
  after_action :associate_with_channel, only: :create

  private

  def check_application_method
    if channel.has_external_application?
      raise ActionController::RoutingError.new('Channel has external application method.')
    end
  end

  def associate_with_channel
    resource.channels << channel
    resource.save
  end
end
