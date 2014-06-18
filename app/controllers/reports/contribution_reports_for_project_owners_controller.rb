class Reports::ContributionReportsForProjectOwnersController < Reports::BaseController
  before_filter :check_if_project_belongs_to_user

  def end_of_association_chain
    reward_id  = params[:reward_id]
    conditions = if reward_id
      { reward_id: (reward_id == '0' ? nil : reward_id) }
    else
      {}
    end

    project = Project.find(params[:project_id])
    ContributionReportsForProjectOwner.new(project, conditions)
  end

  def check_if_project_belongs_to_user
    redirect_to root_path unless policy(Project.find(params[:project_id])).update?
  end
end
