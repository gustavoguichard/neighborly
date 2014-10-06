class ContactsController < ApplicationController
  def new
    @contact = Contact.new
  end

  def create
    @contact = Contact.new(permitted_params[:contact])

    if @contact.save
      flash.notice = { message: t('controllers.contacts.create.success'), dismissible: false }
      return redirect_to contact_path
    else
      render 'new'
    end
  end

  protected
  def permitted_params
    params.permit({ contact: Contact.attribute_names.map(&:to_sym) })
  end
end
