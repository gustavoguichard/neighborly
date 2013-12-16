class Projects::BackersController < ApplicationController
  inherit_resources
  actions :show, :new, :edit, :update, :review, :create, :credits_checkout
  skip_before_filter :force_http, only: [:create]
  skip_before_filter :verify_authenticity_token, only: [:moip]
  has_scope :available_to_count, type: :boolean
  has_scope :with_state
  has_scope :page, default: 1
  load_and_authorize_resource except: [:index]
  belongs_to :project, finder: :find_by_permalink!

  def index
    @project = parent
    if request.xhr? && params[:page] && params[:page].to_i > 1
      render collection
    end
  end

  def update
    resource.update_attributes(params[:backer])
    resource.update_user_billing_info
    render json: { message: 'updated' }
  end

  def show; end

  def new
    return redirect_to :root, flash: { error: t('controllers.projects.backers.new.cannot_back') } unless parent.online?

    @create_url = create_url
    @backer = @project.backers.new(user: current_user)
    @rewards = [empty_reward] + @project.rewards.not_soon.remaining.order(:minimum_value)

    if params[:reward_id] && (selected_reward = @project.rewards.not_soon.find(params[:reward_id])) && !selected_reward.sold_out?
      @backer.reward = selected_reward
      @backer.value = "%0.0f" % selected_reward.minimum_value
    end
  end

  def create
    @backer.user = current_user
    @backer.reward_id = nil if params[:backer][:reward_id].to_i == 0

    create! do |success, failure|
      success.html do
        session[:thank_you_backer_id] = @backer.id
        return redirect_to edit_project_backer_path(project_id: @project, id: @backer.id), flash: { notice: nil }
      end

      failure.html do
        return redirect_to new_project_backer_path(@project), flash: { failure: t('controllers.projects.backers.create.error') }
      end
    end
  end

  def credits_checkout
    return redirect_to new_project_backer_path(@backer.project), flash: { failure: t('controllers.projects.backers.credits_checkout.no_credits') } if current_user.credits < @backer.value

    unless @backer.confirmed?
      @backer.update_attributes({ payment_method: 'Credits' })
      @backer.confirm!
    end

    redirect_to project_backer_path(parent, resource), flash: { success: t('controllers.projects.backers.credits_checkout.success') }
  end

  protected
  def collection
    @backers ||= apply_scopes(end_of_association_chain).available_to_display.order("confirmed_at DESC").per(10)
  end

  def empty_reward
    Reward.new(minimum_value: 0, description: t('controllers.projects.backers.new.no_reward'))
  end

  def create_url
    if ::Configuration[:secure_review_host]
      return project_backers_url(@project, {host: ::Configuration[:secure_review_host], protocol: 'https'})
    else
      return project_backers_path(@project)
    end
  end
end
