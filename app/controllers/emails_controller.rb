class EmailsController < ApplicationController
  def index
    @notifications = []
    types = [
      :adm_project_deadline,
      :contact,
      :payment_confirmed,
      :payment_canceled_after_confirmed,
      :new_draft_project,
      :new_user_registration,
      :project_in_wainting_funds,
      :project_received,
      :project_rejected,
      :project_unsuccessful,
      :project_visible,
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
