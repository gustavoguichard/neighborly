class Users::QuestionsMailer < ActionMailer::Base
  layout 'email'

  def new(question, user, project, asker)
    @question = question
    @user = user
    @project = project
    @asker = asker

    mail(
      from: "#{::Configuration[:company_name]} <#{::Configuration[:email_system]}>",
      reply_to: "#{asker.display_name} <#{asker.email}>",
      to: @user.email,
      subject: "Question Regarding #{@project.name}."
    )
  end
end
