class StaticController < ApplicationController
  def how_it_works
    @title = t('static.how_it_works.title')
  end

  def terms
    @title = t('static.terms.title')
    render layout: false if request.xhr?
  end

  def privacy
    @title = t('static.privacy.title')
    render layout: false if request.xhr?
  end

  def start_terms
    @title = t('static.start_terms.title')
  end

  def start
    @title = t('static.start.title')
  end

  def faq
    @title = t('static.faq.title')
  end

  def thank_you
    backer = Backer.find session[:thank_you_backer_id]
    redirect_to [backer.project, backer]
  end

  def sitemap
    # TODO: update this sitemap to use new homepage logic
    @home_page    ||= Project.includes(:user, :category).visible.limit(6)
    @expiring     ||= Project.includes(:user, :category).visible.expiring.not_expired.order("(projects.expires_at), created_at DESC").limit(3)
    @recent       ||= Project.includes(:user, :category).visible.not_expiring.not_expired.where("projects.user_id <> 7329").order('created_at DESC').limit(3)
    @successful   ||= Project.includes(:user, :category).visible.successful.order("(projects.expires_at) DESC").limit(3)
    return render 'sitemap'
  end

end
