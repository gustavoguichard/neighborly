class ProjectsMailer < ActionMailer::Base
  layout 'email'

  def contact_about_reward_email(params, project)
    @params = params
    @project = project

    mail(
      from: "#{I18n.t('site.name')} <#{I18n.t('site.email.system')}>",
      to: 'howdy@neighbor.ly',
      subject: "Contact about reward of project #{@project.name}."
    )
  end
end
