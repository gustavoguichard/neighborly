class Projects::ContributionsController < ApplicationController
  after_filter :verify_authorized, except: :index
  inherit_resources
  actions :show, :new, :edit, :create, :credits_checkout
  skip_before_filter :force_http, only: [:create, :edit, :update, :credits_checkout]
  skip_before_filter :verify_authenticity_token, only: [:moip]
  skip_before_filter :set_persistent_warning
  has_scope :available_to_count, type: :boolean
  has_scope :with_state
  has_scope :page, default: 1
  belongs_to :project, finder: :find_by_permalink!

  def index
    @project = parent
    if request.xhr? && params[:page] && params[:page].to_i > 1
      render collection
    end
  end

  def edit
    authorize resource
  end

  def show
    authorize resource
  end

  def new
    @contribution = Contribution.new(project: parent, user: current_user)
    authorize @contribution

    @create_url = create_url
    @rewards = [empty_reward] + @project.rewards.not_soon.remaining.order(:minimum_value)

    if params[:reward_id] && (selected_reward = @project.rewards.not_soon.find(params[:reward_id])) && !selected_reward.sold_out?
      @contribution.reward = selected_reward
      @contribution.value = "%0.0f" % selected_reward.minimum_value
    end
  end

  def create
    @contribution = Contribution.new(permitted_params[:contribution].
                                     merge(user: current_user,
                                           project: parent))

    @contribution.reward_id = nil if params[:contribution][:reward_id].to_i == 0
    authorize @contribution

    create! do |success, failure|
      success.html do
        session[:thank_you_contribution_id] = @contribution.id
        flash.delete(:notice)
        return redirect_to edit_project_contribution_path(project_id: @project, id: @contribution.id)
      end

      failure.html do
        return redirect_to new_project_contribution_path(@project), flash: { failure: t('controllers.projects.contributions.create.error') }
      end
    end
  end

  def credits_checkout
    authorize resource
    if current_user.credits < @contribution.value
      flash.alert = t('controllers.projects.contributions.credits_checkout.no_credits')
      return redirect_to new_project_contribution_path(@contribution.project)
    end

    unless @contribution.confirmed?
      @contribution.update_attributes({ payment_method: 'Credits' })
      @contribution.confirm!
    end

    flash.notice = t('controllers.projects.contributions.credits_checkout.success')
    redirect_to project_contribution_path(parent, resource)
  end

  protected
  def permitted_params
    params.permit(policy(@contribution || Contribution).permitted_attributes)
  end

  def collection
    @contributions ||= apply_scopes(end_of_association_chain).available_to_display.order("confirmed_at DESC").per(10)
  end

  def empty_reward
    Reward.new(minimum_value: 0, description: t('controllers.projects.contributions.new.no_reward'))
  end

  def create_url
    if ::Configuration[:secure_review_host]
      return project_contributions_url(@project, {host: ::Configuration[:secure_review_host], protocol: 'https'})
    else
      return project_contributions_path(@project)
    end
  end
end
