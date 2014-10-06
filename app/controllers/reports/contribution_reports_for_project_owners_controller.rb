class Reports::ContributionReportsForProjectOwnersController < Reports::BaseController
  before_filter :check_if_project_belongs_to_user
  respond_to :csv

  def index
    reward_id  = params[:reward_id]
    conditions = if reward_id
      { reward_id: (reward_id == '0' ? nil : reward_id) }
    else
      {}
    end

    project = Project.find_by_permalink!(params[:project_id])
    respond_with ContributionReportsForProjectOwner.per_project(project, conditions)
  end

  private

  def check_if_project_belongs_to_user
    redirect_to root_path unless policy(Project.find_by_permalink!(params[:project_id])).update?
  end
end

