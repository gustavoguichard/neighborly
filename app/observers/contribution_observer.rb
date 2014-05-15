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
       contribution.project.notify_owner(:project_success)
    end
  end

  def from_confirmed_to_canceled(resource)
    notification_for_backoffice(resource, :contribution_canceled_after_confirmed)
  end

  def from_confirmed_to_requested_refund(resource)
    notification_for_backoffice(resource, :refund_request)
  end

  private
  def notify_confirmation(contribution)
    contribution.update(confirmed_at: Time.now)
    contribution.notify_owner(:confirm_contribution,
                              { },
                              { bcc: ::Configuration[:email_payments] })

    if contribution.project.expires_at < 7.days.ago
      notification_for_backoffice(contribution, :contribution_confirmed_after_project_was_closed)
    end
  end

  def generate_matches(contribution)
    unless contribution.payment_method.eql?(:matched)
      MatchedContributionGenerator.new(contribution).create
    end
  end

  def notification_for_backoffice(resource, template_name, options = {})
    user = User.find_by(email: Configuration[:email_payments])

    if user
      Notification.notify_once(template_name,
                               user,
                               { contribution_id: resource.id },
                               { contribution:    resource }.merge!(options)
      )
    end
  end
end
