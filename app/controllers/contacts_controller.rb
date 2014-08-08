class ContactsController < ApplicationController
  inherit_resources
  actions :new, :create

  def create
    create! do
      flash.notice = { message: t('controllers.contacts.create.success'), dismissible: false }
      return redirect_to contact_path
    end
  end

  protected
  def permitted_params
    params.permit({ contact: Contact.attribute_names.map(&:to_sym) })
  end
end
