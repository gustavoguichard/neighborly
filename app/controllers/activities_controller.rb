class ActivitiesController < ApplicationController
  before_action :set_activity, only: [:edit, :update, :destroy]
  respond_to :html

  def new
    @activity = parent.activities.build
    authorize @activity
  end

  def edit
    authorize @activity
  end

  def create
    @activity = parent.activities.build(activity_params.merge(user: current_user))
    authorize @activity

    @activity.save
    respond_with @activity, location: project_path(parent)
  end

  def update
    authorize @activity
    @activity.update(activity_params)
    respond_with @activity, location: project_path(parent)
  end

  def destroy
    authorize @activity
    @activity.destroy
    redirect_to project_path(parent)
  end

  private

  def parent
    @project ||= Project.find_by_permalink!(params[:project_id])
  end

  def set_activity
    @activity = Activity.find(params[:id])
  end

  def activity_params
    params.permit(policy(Activity).permitted_attributes)[:activity]
  end
end
