class EmailsController < ApplicationController
  def index
    @notifications = []
    types = [
      :adm_project_deadline,
      :company_contact,
      :confirm_contribution,
      :contribution_canceled_after_confirmed,
      :contribution_confirmed_after_project_was_closed,
      :contribution_project_successful,
      :contribution_project_unsuccessful,
      :credits_warning,
      :new_draft_project,
      :new_draft_project_channel,
      :new_project_visible,
      :new_user_registration,
      :payment_slip,
      :pending_contribution_project_unsuccessful,
      :project_in_wainting_funds,
      :project_owner_contribution_confirmed,
      :project_received,
      :project_received_channel,
      :project_rejected,
      :project_rejected_channel,
      :project_success,
      :project_unsuccessful,
      :project_visible,
      :project_visible_channel
    ]

    types.each do |type|
      notification = Notification.where(template_name: type).last
      @notifications << notification if notification
    end
  end

  def show
    @notification = Notification.find params[:id]
    #header = render_to_string(template: "notifications_mailer/subjects/#{@notification.template_name}", formats: [:text, :html])
    message = OpenStruct.new
    message.subject = ''
    render "notifications_mailer/#{@notification.template_name}", layout: 'email', locals: { message: message }
  end
end
