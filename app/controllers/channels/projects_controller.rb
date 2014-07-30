class Channels::ProjectsController < ProjectsController
  belongs_to :channel, finder: :find_by_permalink!, param: :profile_id

  after_action :associate_with_channel, only: :create

  prepend_before_filter{ params[:profile_id] = request.subdomain }

  private

  def associate_with_channel
    resource.channels << channel
  end
end
