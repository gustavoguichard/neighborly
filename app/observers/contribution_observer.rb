class ContributionObserver < ActiveRecord::Observer
  def after_create(contribution)
    generate_matches(contribution)
  end

  def after_save(contribution)
    if contribution.project.reached_goal?
       contribution.project.notify_owner(:project_success)
    end
  end

  private

  def generate_matches(contribution)
    unless contribution.payment_method.eql?(:matched)
      MatchedContributionGenerator.new(contribution).create
    end
  end
end
