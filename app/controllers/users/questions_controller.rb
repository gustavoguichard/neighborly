class Users::QuestionsController < ApplicationController
  def new
    @project = Project.find(params[:project_id])

    unless current_user
      session[:return_to] = project_path(@project, anchor: 'open-new-user-question-modal')
      return redirect_to new_user_session_path
    end
    @user = parent
    render layout: false
  end

  def create
    project = Project.find(params[:project_id])
    unless current_user
      session[:return_to] = project_path(project, anchor: 'open-new-user-question-modal')
      return redirect_to new_user_session_path
    end

    Users::QuestionsMailer.new(params[:question][:body], parent, project, current_user).deliver
    flash.notice = "#{parent.display_name} received your question and will be in touch shortly."
    redirect_to project_path(project)
  end

  private

  def parent
    @user ||= User.find(params[:user_id])
  end
end
