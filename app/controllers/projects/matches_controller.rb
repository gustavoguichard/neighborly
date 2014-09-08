class Projects::MatchesController < ApplicationController
  before_filter :authenticate_user!
  after_filter :verify_authorized

  def new
    @project = parent
    @match   = parent.matches.build
    authorize @match
  end

  def create
    @project = parent
    @match   = Match.new(
      match_params.except(:starts_at, :finishes_at).
        merge(project: parent, user: current_user)
    )
    authorize @match

    @match.starts_at   = Date.strptime(
      match_params[:starts_at], '%m/%d/%y'
    ).in_time_zone
    @match.finishes_at = Date.strptime(
      match_params[:finishes_at], '%m/%d/%y'
    ).in_time_zone

    if @match.save
      redirect_to edit_project_match_path(parent, @match)
    else
      flash.alert = @match.errors.messages.values.flatten.to_sentence
      render 'new'
    end
  end

  def edit
    @project = parent
    @match   = resource
    authorize resource
  end

  def show
    @project = parent
    @match   = resource
    authorize resource
  end

  protected

  def match_params
    params.require(:match).permit(
      %i(
        starts_at
        finishes_at
        value_unit
        value
      )
    )
  end

  def parent
    @parent ||= Project.find_by_permalink!(params[:project_id])
  end

  def resource
    @resource ||= parent.matches.find(params[:id])
  end
end
