class Projects::Challenges::MatchesController < ApplicationController
  inherit_resources
  actions :new, :create
  helper_method :parent

  def parent
    @project ||= Project.find_by(permalink: params[:project_id])
  end
end
