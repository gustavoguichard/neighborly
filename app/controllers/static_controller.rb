class StaticController < ApplicationController
  def terms
    render layout: false if request.xhr?
  end

  def privacy
    render layout: false if request.xhr?
  end

  def start_terms; end
  def start; end

  def faq
    authorize :static, :faq?
  end

  def about
    @team_members = YAML.load(File.read(File.expand_path('app/views/static/team.yml', Rails.root)))
  end

  def thank_you
    contribution = Contribution.find session[:thank_you_contribution_id]
    redirect_to [contribution.project, contribution]
  end

  def sitemap
    # TODO: update this sitemap to use new homepage logic
    @home_page    ||= Project.includes(:user).visible.limit(6)
    @expiring     ||= Project.includes(:user).visible.expiring.not_expired.order("(projects.expires_at), created_at DESC").limit(3)
    @recent       ||= Project.includes(:user).visible.not_expiring.not_expired.where("projects.user_id <> 7329").order('created_at DESC').limit(3)
    @successful   ||= Project.includes(:user).visible.successful.order("(projects.expires_at) DESC").limit(3)
  end
end
