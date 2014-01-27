class RewardsController < ApplicationController
  load_and_authorize_resource
  inherit_resources
  belongs_to :project, finder: :find_by_permalink!
  respond_to :html, :json

  def index; end

  def new; end

  def edit; end

  def update
    update! { project_path(parent) }
  end

  def create
    create! { project_path(parent) }
  end

  def destroy
    destroy! { project_path(resource.project) }
  end

  def sort
    resource.update_attribute :row_order_position, params[:reward][:row_order_position]

    render nothing: true
  end
end
