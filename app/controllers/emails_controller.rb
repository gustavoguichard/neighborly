class EmailsController < ApplicationController
  def index
    @notifications = []
    types = [
      :adm_project_deadline,
      :contact,
      :payment_confirmed,
      :payment_canceled_after_confirmed,
      :payment_confirmed_after_finished_project,
      :contribution_project_successful,
      :contribution_project_unsuccessful,
      :new_draft_project,
      :new_draft_project_channel,
      :new_project_visible,
      :new_user_registration,
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
    message = OpenStruct.new
    message.subject = ''
    render "notifications_mailer/#{@notification.template_name}", layout: 'email', locals: { message: message }
  end
end
