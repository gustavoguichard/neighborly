class Admin::ProjectsController < Admin::BaseController
  defaults finder: :find_by_permalink!

  has_scope :by_user_email, :by_id, :pg_search, :user_name_contains, :with_state, :by_category_id, :order_by
  has_scope :between_created_at, :between_expires_at, :between_online_date, :between_updated_at, :goal_between, using: [ :start_at, :ends_at ]

  before_filter do
    @total_projects = Project.count
  end

  [:approve, :reject, :push_to_draft, :push_to_soon].each do |name|
    define_method name do
      @project = Project.find_by_permalink params[:id]
      @project.send("#{name.to_s}!")
      redirect_to :back
    end
  end

  def populate
    if params[:user][:id].present?
      @user = User.find(params[:user][:id])
    else
      @user = create_user
    end

    @contribution = build_contribution(@user)

    if @user.valid? and @contribution.valid?
      @user.save!
      @contribution.save!
      redirect_to populate_contribution_admin_project_path(resource), flash: { success: 'Success!' }
    else
      flash.alert = (@user.errors.full_messages +
                     @contribution.errors.full_messages).to_sentence
      render :populate_contribution
    end
  end

  def destroy
    resource.push_to_trash! if resource.can_push_to_trash?
    redirect_to admin_projects_path
  end

  protected
  def collection
    @projects = apply_scopes(end_of_association_chain).order('projects.created_at desc').with_project_totals.without_state('deleted').page(params[:page])
  end

  def create_user
    password = Devise.friendly_token
    user = User.new(params[:user])
    user.email = "#{Devise.friendly_token}@populate.user"
    user.password = password
    user.password_confirmation = password
    user.profile_type = params[:user][:profile_type]
    user
  end

  def build_contribution(user)
    contribution = resource.contributions.new(params[:contribution])
    contribution.payment_method = 'PrePopulate'
    contribution.state = 'confirmed'
    contribution.user = user
    contribution
  end
end
