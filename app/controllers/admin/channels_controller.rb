class Admin::ChannelsController < Admin::BaseController
  defaults finder: :find_by_permalink
  actions :all, except: [:show]
  def collection
    @channels = apply_scopes(end_of_association_chain).page(params[:page])
  end
end
