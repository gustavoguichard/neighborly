class Projects::MatchesController < ApplicationController
  before_filter :authenticate_user!
  after_filter :verify_authorized
  inherit_resources
  actions :all, except: %i(index destroy)
  belongs_to :project, finder: :find_by_permalink!

  def new
    @match = parent.matches.build
    authorize @match
  end

  def create
    @match = Match.new(
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
      redirect_to parent
    else
      flash.alert = @match.errors.full_messages.to_sentence
      render 'new'
    end
  end

  def edit
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
end
