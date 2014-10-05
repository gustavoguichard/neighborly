class Users::ProjectsController < ApplicationController
  def index
    authorize parent, :update?
    @projects = parent.projects
  end

  private

  def parent
    @user ||= User.find(params[:user_id])
  end
end
