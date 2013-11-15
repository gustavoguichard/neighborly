# coding: utf-8
class ProjectsController < ApplicationController
  include SimpleCaptcha::ControllerHelpers

  load_and_authorize_resource only: [ :new, :create, :update, :destroy ]
  inherit_resources
  defaults finder: :find_by_permalink!
  has_scope :pg_search, :by_category_id
  has_scope :recent, :expiring, :successful, :recommended, :not_expired, :not_soon, :soon, type: :boolean

  respond_to :html
  respond_to :json, only: [:index, :show, :update]

  def index
    if request.xhr?
      params[:not_soon] = 'true' unless params.include?(:soon)
      params[:not_expired] = 'true' if params.include?(:recommended)
      projects = apply_scopes(Project).visible.order_for_search.includes(:project_total, :user, :category).page(params[:page]).per(4)
      return render partial: 'project', collection: projects, layout: false
    else
      if current_user && current_user.address.present?
        @city = current_user.address
      elsif request.location.present? && request.location.city.present? && request.location.country_code == 'US'
        @city = request.location.city
      else
        @city = 'Kansas City, MO'
      end
      @project_locations = Project.with_state('online').locations
      @project_locations = @project_locations.concat([@city]) unless @project_locations.include?(@city)

      @press_assets = PressAsset.order('created_at DESC').limit(5)
      @featured = Project.with_state('online').featured.limit(1).first
      @recommended = Project.with_state('online').recommended.home_page.limit(1).first
      @near_projects = Project.with_state('online').near(@city, 50).order('distance').limit(4)
      @ending_soon = Project.expiring.home_page.limit(4)
      @coming_soon = Project.soon.home_page.limit(8)
    end
  end

  def near
    #if request.xhr?
      projects = apply_scopes(Project).with_state('online').near(params[:location], 30).visible.order('distance').page(params[:page]).per(4)
      return render partial: 'project', collection: projects, layout: false
    #else
      #raise ActionController::UnknownController
    #end
  end

  def new
    new! do
      @project.rewards.build
    end
  end

  def create
    @project = current_user.projects.new(params[:project])

    create!(notice: t('projects.create.success')) do |success, failure|
      success.html do
        session[:successful_created] = resource.id
        return redirect_to success_project_path(@project)
      end
    end
  end

  def success
    session[:successful_created] = resource.id
    redirect_to project_path(resource) unless session[:successful_created] == resource.id
  end

  def update
    update! do |success, failure|
      success.html{ return redirect_to edit_project_path(@project) }
      failure.html{ return redirect_to edit_project_path(@project) }
    end
  end

  def show
    fb_admins_add(resource.user.facebook_id) if resource.user.facebook_id
    @update = resource.updates.where(id: params[:update_id]).first if params[:update_id].present?
    render :about if request.xhr?
  end

  def comments
    @project = resource
  end

  def reports
    @project = resource
  end

  def budget
    @project = resource
  end

  def video
    project = Project.new(video_url: params[:url])
    render json: project.video.to_json
  end

  %w(embed video_embed).each do |method_name|
    define_method method_name do
      @title = resource.name
      render layout: 'embed'
    end
  end

  def embed_panel
    @title = resource.name
    render layout: false
  end

  def send_reward_email
    if simple_captcha_valid?
      ProjectsMailer.contact_about_reward_email(params, resource).deliver
      flash[:notice] = 'We\'ve received your request and will be in touch shortly.'
    else
      flash[:error] = 'The code is not valid. Try again.'
    end
    redirect_to project_path(resource)
  end

  def reward_contact
    render layout: !request.xhr?
  end
end
