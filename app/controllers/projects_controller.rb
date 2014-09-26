# coding: utf-8
class ProjectsController < ApplicationController
  after_filter :verify_authorized, except: [:index, :video, :video_embed, :embed,
                                            :embed_panel, :budget,
                                            :reward_contact, :send_reward_email,
                                            :start, :statement]

  respond_to :html

  def new
    @project = Project.new(user: current_user)
    authorize @project
  end

  def index
    projects_vars = {
      #coming_soon: :soon,
      #ending_soon: :expiring,
      featured:    :featured,
      recommended: :recommends,
      successful:  :successful
    }

    projects_vars.each do |var_name, scope|
      instance_variable_set "@#{var_name}", ProjectsForHome.send(scope)
    end

    @successful = @successful.take(2) if browser.mobile?
    @channels = Channel.with_state('online').order('RANDOM()').limit(4)
    @users = User.where('uploaded_image IS NOT NULL').with_profile_type('personal').order("RANDOM()").limit(18)
  end

  def create
    @project = Project.new(permitted_params[:project].merge(user: current_user))
    authorize @project
    @project.save
    respond_with @project, location: success_project_path(@project)
  end

  def success
    authorize resource
  end

  def edit
    authorize resource
    respond_with resource
  end

  def update
    authorize resource
    respond_with Project.update(resource.id, permitted_params[:project]),
      location: edit_project_path(@project)
  end

  def show
    authorize resource
    set_facebook_url_admin(resource.user)
    render :about if request.xhr?
  end

  def reports
    authorize resource
  end

  def statement
    @project = resource
  end

  def budget
    @project = resource
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

  def start
    @projects = ProjectsForHome.successful[0..3]
    @channel  = channel.decorate if channel
  end

  private

  def permitted_params
    params.permit(policy(@project || Project).permitted_attributes)
  end

  def resource
    @project ||= Project.find_by_permalink!(params[:id])
  end

  def permitted_params
    params.permit(policy(@project || Project).permitted_attributes)
  end
end
