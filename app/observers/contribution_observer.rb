class ContributionObserver < ActiveRecord::Observer
  observe :contribution

  def after_create(contribution)
    contribution.define_key
    generate_matches(contribution)
  end

  def before_save(contribution)
    notify_confirmation(contribution) if contribution.confirmed? && contribution.confirmed_at.nil?
  end

  def after_save(contribution)
    if contribution.project.reached_goal?
      Notification.notify_once(
        :project_success,
        contribution.project.user,
        {project_id: contribution.project.id},
        project: contribution.project
      )
    end
  end

  def notify_backoffice(contribution)
    user = User.where(email: Configuration[:email_payments]).first
    if user.present?
      Notification.notify_once(
        :refund_request,
        user,
        {contribution_id: contribution.id},
        contribution: contribution
      )
    end
  end

  def notify_backoffice_about_canceled(contribution)
    user = User.where(email: Configuration[:email_payments]).first
    if user.present?
      Notification.notify_once(
        :contribution_canceled_after_confirmed,
        user,
        {contribution_id: contribution.id},
        contribution: contribution
      )
    end
  end

  private

  def generate_matches(contribution)
    unless contribution.payment_method.eql?(:matched)
      MatchedContributionGenerator.new(contribution).create
    end
  end

  def notify_confirmation(contribution)
    contribution.confirmed_at = Time.now
    Notification.notify_once(
      :confirm_contribution,
      contribution.user,
      {contribution_id: contribution.id},
      contribution: contribution,
      project: contribution.project,
      bcc: ::Configuration[:email_payments]
    )

    if (Time.now > contribution.project.expires_at  + 7.days) && (user = User.where(email: ::Configuration[:email_payments]).first)
      Notification.notify_once(
        :contribution_confirmed_after_project_was_closed,
        user,
        {contribution_id: contribution.id},
        contribution: contribution,
        project: contribution.project
      )
    end
  end
end
