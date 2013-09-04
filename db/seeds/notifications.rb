user = User.first
project = Project.first
backer = Backer.first
payment_notification = PaymentNotification.first

Notification.create_notification_once(:adm_project_deadline,
  user,
  {project_id: project.id},
  project: project,
  from: ::Configuration[:email_system],
  project_name: project.name)


Notification.create_notification_once(:backer_canceled_after_confirmed,
  user,
  {backer_id: backer.id},
  backer: backer)

Notification.create_notification_once(:backer_confirmed_after_project_was_closed,
  user,
  {backer_id: backer.id},
  backer: backer,
  project_name: backer.project.name)

Notification.create_notification_once(
  :backer_project_successful,
  backer.user,
  {backer_id: backer.id},
  backer: backer,
  project: project,
  project_name: project.name)

Notification.create_notification_once(
  :backer_project_unsuccessful,
  backer.user,
  {backer_id: backer.id},
  backer: backer,
  project: project,
  project_name: project.name)

Notification.create_notification_once(:confirm_backer,
  backer.user,
  {backer_id: backer.id},
  backer: backer,
  project_name: backer.project.name)

Notification.create_notification_once(:credits_warning,
  backer.user,
  {backer_id: backer.id},
  backer: backer,
  amount: backer.user.credits)

Notification.create_notification_once(:new_draft_project,
                                      user,
                                      {project_id: project.id},
                                      {project: project, project_name: project.name, from: project.user.email, display_name: project.user.display_name}
                                     )

Notification.create_notification_once(:project_received,
                                      project.user,
                                      {project_id: project.id},
                                      {project: project, project_name: project.name})

#Notification.create_notification_once(:project_received_channel,
                                      #project.user,
                                      #{project_id: project.id},
                                      #{project: project, project_name: project.name})

Notification.create_notification_once(:new_project_visible,
  user,
  {project_id: project.id, user_id: user.id},
  project: project)

Notification.create_notification_once(:new_user_registration, user, {user_id: user.id}, {user: user})

Notification.create_notification_once(:payment_slip,
  backer.user,
  {backer_id: backer.id},
  backer: backer,
  project_name: backer.project.name)

Notification.create_notification_once(
  :pending_backer_project_unsuccessful,
  backer.user,
  {backer_id: backer.id},
  {backer: backer, project: project, project_name: project.name })

Notification.create_notification_once(:processing_payment,
  payment_notification.backer.user,
  {backer_id: payment_notification.backer.id},
  backer: payment_notification.backer,
  project_name: payment_notification.backer.project.name,
  payment_method: payment_notification.backer.payment_method)

Notification.create_notification_once(:project_in_wainting_funds,
  project.user,
  {project_id: project.id},
  project: project)

Notification.create_notification_once(:project_owner_backer_confirmed,
  backer.project.user,
  {backer_id: backer.id},
  backer: backer,
  project_name: backer.project.name)

Notification.create_notification_once(:project_rejected,
  project.user,
  {project_id: project.id},
  project: project)

Notification.create_notification_once(:project_success,
  project.user,
  {project_id: project.id},
  project: project)

Notification.create_notification_once(:project_unsuccessful,
  project.user,
  {project_id: project.id, user_id: project.user.id},
  project: project) unless project.successful?

Notification.create_notification_once(:project_visible,
  project.user,
  {project_id: project.id},
  project: project)
