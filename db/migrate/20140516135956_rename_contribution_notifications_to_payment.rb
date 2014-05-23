class RenameContributionNotificationsToPayment < ActiveRecord::Migration
  def up
    Notification.where(template_name: 'confirm_contribution').update_all(template_name: 'payment_confirmed')
    Notification.where(template_name: 'contribution_canceled_after_confirmed').update_all(template_name: 'payment_canceled_after_confirmed')
    Notification.where(template_name: 'contribution_confirmed_after_project_was_closed').update_all(template_name: 'payment_confirmed_after_finished_project')
  end

  def down
    Notification.where(template_name: 'payment_confirmed').update_all(template_name: 'confirm_contribution')
    Notification.where(template_name: 'payment_canceled_after_confirmed').update_all(template_name: 'contribution_canceled_after_confirmed')
    Notification.where(template_name: 'payment_confirmed_after_finished_project').update_all(template_name: 'contribution_confirmed_after_project_was_closed')
  end
end
