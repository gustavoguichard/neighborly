class ContributionObserver < ActiveRecord::Observer
  def after_create(contribution)
    update_project_total(contribution.project)
    generate_matches(contribution)
  end

  def after_save(contribution)
    if contribution.project.reached_goal?
       contribution.project.notify_owner(:project_success)
    end
  end

  def after_transition(contribution, transition)
    update_project_total(contribution.project)
  end

  private

  def generate_matches(contribution)
    unless contribution.payment_method.eql?(:matched)
      MatchedContributionGenerator.new(contribution).create
    end
  end

  def update_project_total(project)
    ProjectTotalBuilder.new(project).perform
  end
end
