class ContributionObserver < ActiveRecord::Observer
  def after_create(contribution)
    update_project_total(contribution.project)
  end

  def after_transition(contribution, transition)
    update_project_total(contribution.project)
  end

  def after_wait_broker(contribution, transition)
    user = User.find_by!(email: Configuration[:email_new_order])
    Notification.notify_once(
      :new_order,
      user,
      { contribution_id: contribution.id },
      contribution_id: contribution.id,
      project_id: contribution.project_id,
    )
  end

  private

  def update_project_total(project)
    ProjectTotalBuilder.new(project).perform
  end
end
