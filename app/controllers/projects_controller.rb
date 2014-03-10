# coding: utf-8
class ProjectsController < ApplicationController
  include SimpleCaptcha::ControllerHelpers

  load_and_authorize_resource only: [ :new, :create, :edit, :update, :send_to_analysis]
  inherit_resources
  actions :new, :create, :edit, :update
  defaults finder: :find_by_permalink!
  has_scope :pg_search, :by_category_id
  has_scope :recent, :expiring, :successful, :recommended, :not_expired, :not_soon, :soon, type: :boolean

  respond_to :html
  respond_to :json, only: [:index, :show, :update]

  def index
    @city = user_city
    @project_locations = project_locations(@city)

    used_ids = [0]
    @featured = Project.with_state('online').featured.limit(1).first
    used_ids << @featured.id if @featured

    @recommended = Project.with_state('online').recommended.home_page.limit(1).where('id NOT IN (?)', used_ids).first
    used_ids << @recommended.id if @recommended

    @near_projects = Project.with_state('online').near(@city, 100).visible.order('distance').limit(4)
    used_ids += @near_projects.map(&:id) if @near_projects.any?

    @successful = Project.visible.successful.home_page.limit(4)
    @ending_soon = Project.expiring.home_page.where('id NOT IN (?)', used_ids).limit(4)
    @coming_soon = Project.soon.home_page.limit(4)
    @channels = Channel.with_state('online').order('RANDOM()').limit(4)
    @press_assets = PressAsset.order('created_at DESC').limit(5)
  end

  def near
    raise ActionController::UnknownController unless request.xhr?
    @projects = apply_scopes(Project).with_state('online').near(params[:location], 100).visible.order('distance').page(params[:page]).per(4)
    render layout: false
  end

  def create
    @project = current_user.projects.new(params[:project])
    create! do |success, failure|
      success.html do
        session[:successful_created] = resource.id
        return redirect_to success_project_path(@project)
      end
    end
  end

  def send_to_analysis
    resource.send_to_analysis
    flash[:notice] = t('projects.send_to_analysis')
    redirect_to project_path(@project)
  end

  def success
    redirect_to project_path(resource) unless session[:successful_created] == resource.id
    session[:successful_created] = false
  end

  def update
    update! do |success, failure|
      success.html{ return redirect_to edit_project_path(@project) }
      failure.html{ return redirect_to edit_project_path(@project) }
    end
  end

  def show
    redirect_to(root_path) unless can? :show_project, resource
    fb_admins_add(resource.user.facebook_id) if resource.user.facebook_id
    render :about if request.xhr?
  end

  def comments
    @project = resource
  end

  def reports
    redirect_to(new_user_session_path) unless can? :update, resource
    @project = resource
  end

  def budget
    @project = resource
  end

  def video
    project = Project.new(video_url: params[:url])
    render json: project.video.to_json
  rescue VideoInfo::UrlError
    render json: nil
  end

  %w(embed video_embed).each do |method_name|
    define_method method_name do
      @title = resource.name
      render layout: 'embed'
    end
  end

  def embed_panel
    @project = resource
    render layout: !request.xhr?
  end

  def send_reward_email
    if simple_captcha_valid?
      ProjectsMailer.contact_about_reward_email(params, resource).deliver
      flash[:notice] = 'We\'ve received your request and will be in touch shortly.'
    else
      flash.alert = 'The code is not valid. Try again.'
    end
    redirect_to project_path(resource)
  end

  def reward_contact
    render layout: !request.xhr?
  end

  def start
    @projects = Project.visible.successful.home_page.limit(3)
  end

  private
  def user_city
    if current_user && current_user.address.present?
      current_user.address
    #elsif request.location.present? && request.location.city.present? && request.location.country_code == 'US'
      #request.location.city
    else
      'Kansas City, MO'
    end
  end

  def project_locations(current_city)
    locations = Project.with_state('online').locations
    locations.concat([current_city]) unless locations.include?(current_city)
    locations
  end
end
