class MatchesController < ApplicationController
  before_filter :authenticate_user!
  inherit_resources
  actions :new
  helper_method :parent

  def create
    @match = Match.new(
      match_params.except(:starts_at, :finishes_at).
        merge(project: parent, user: current_user)
    )
    @match.starts_at   = Date.strptime(
      match_params[:starts_at], '%m/%d/%y'
    ).in_time_zone
    @match.finishes_at = Date.strptime(
      match_params[:finishes_at], '%m/%d/%y'
    ).in_time_zone

    if @match.save
      redirect_to parent
    else
      flash.alert = @match.errors.full_messages.to_sentence
      render 'new'
    end
  end

  def parent
    @project ||= Project.find_by(permalink: params[:project_id])
  end

  protected

  def match_params
    params.require(:match).permit(
      %i(
        starts_at
        finishes_at
        value
        maximum_value
      )
    )
  end
end
