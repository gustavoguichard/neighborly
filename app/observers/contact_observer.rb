class ContactObserver < ActiveRecord::Observer
  def after_create(contact)
    user = User.where(email: Configuration[:email_contact]).first

    if user
      Notification.notify_once(
        :contact,
        user,
        {contact_id: contact.id},
        contact: contact
      )
    else
      Rails.logger.info "contact notification --->>> User #{Configuration[:email_contact]} not found"
    end
  end
end
