class RewardsController < ApplicationController
  after_filter :verify_authorized, except: :index
  helper_method :parent
  respond_to :html

  def index
    @rewards = parent.rewards.rank(:row_order)
    respond_with @rewards, layout: !request.xhr?
  end

  def new
    @reward = Reward.new(project: parent)
    authorize @reward
    respond_with @reward, layout: !request.xhr?
  end

  def create
    @reward = Reward.new(permitted_params[:reward].merge(project: parent))
    authorize @reward
    @reward.save
    respond_with @reward, location: project_path(parent)
  end

  def edit
    authorize resource
    respond_with resource, layout: !request.xhr?
  end

  def update
    authorize resource
    respond_with Reward.update(resource.id, permitted_params[:reward]),
      location: project_path(parent)
  end

  def destroy
    authorize resource
    resource.delete
    respond_with resource, location: project_path(parent)
  end

  def sort
    authorize resource
    resource.update_attribute :row_order_position, params[:reward][:row_order_position]

    render nothing: true
  end

  private

  def resource
    @reward ||= parent.rewards.find(params[:id])
  end

  def parent
    @project ||= Project.find_by_permalink!(params[:project_id])
  end

  def permitted_params
    params.permit(policy(@reward || Reward).permitted_attributes)
  end
end
