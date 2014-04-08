class RewardsController < ApplicationController
  after_filter :verify_authorized, except: :index
  inherit_resources
  belongs_to :project, finder: :find_by_permalink!
  respond_to :html, :json

  def index
    render layout: !request.xhr?
  end

  def new
    @reward = Reward.new(project: parent)
    authorize @reward
    render layout: !request.xhr?
  end

  def edit
    authorize resource
    render layout: !request.xhr?
  end

  def update
    authorize resource
    update! { project_path(parent) }
  end

  def create
    @reward = Reward.new(permitted_params[:reward].merge(project: parent))
    authorize resource
    create! { project_path(parent) }
  end

  def destroy
    authorize resource
    destroy! { project_path(resource.project) }
  end

  def sort
    authorize resource
    resource.update_attribute :row_order_position, params[:reward][:row_order_position]

    render nothing: true
  end

  private
  def permitted_params
    params.permit(policy(@reward || Reward).permitted_attributes)
  end
end
