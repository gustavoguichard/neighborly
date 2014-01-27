class CreditsMailer < ActionMailer::Base
  include ERB::Util

  def request_refund_from(contribution)
    @contribution = contribution
    @user = contribution.user
    mail(from: "#{@user.name} <#{@user.email}>", to: ::Configuration[:email_payments], subject: I18n.t('credits_mailer.request_refund_from.subject', name: @contribution.project.name))
  end
end
