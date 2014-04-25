class Projects::Challenges::MatchesController < ApplicationController
  inherit_resources
  actions :new, :create
  helper_method :parent

  def create
    @match = Projects::Challenges::Match.new(
      match_params.except(:starts_at, :finishes_at).
        merge(project: parent, user: current_user)
    )
    @match.starts_at   = Date.strptime(
      match_params[:starts_at], '%m/%d/%y'
    ).in_time_zone
    @match.finishes_at = Date.strptime(
      match_params[:finishes_at], '%m/%d/%y'
    ).in_time_zone

    create! { parent }
  end

  def parent
    @project ||= Project.find_by(permalink: params[:project_id])
  end

  protected

  def match_params
    params.require(:projects_challenges_match).permit(
      %i(
        starts_at
        finishes_at
        value
        maximum_value
      )
    )
  end
end
