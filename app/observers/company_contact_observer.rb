class CompanyContactObserver < ActiveRecord::Observer
  observe :company_contact

  def after_create(company_contact)
    user = User.where(email: Configuration[:email_contact]).first

    if user
      Notification.notify_once(
        :company_contact,
        user,
        {company_contact_id: company_contact.id},
        company_contact: company_contact
      )
    else
      Rails.logger.info "company_contact notification --->>> User #{Configuration[:email_contact]} not found"
    end
  end
end
