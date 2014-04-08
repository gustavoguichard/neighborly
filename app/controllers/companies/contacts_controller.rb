class Companies::ContactsController < ApplicationController
  inherit_resources
  defaults class_name: 'CompanyContact'
  actions :new, :create

  def create
    create! do
      flash.notice = { message: t('controllers.companies.contacts.create.success'), dismissible: false }
      return redirect_to companies_contact_path
    end
  end

  protected
  def permitted_params
    params.permit({ company_contact: CompanyContact.attribute_names.map(&:to_sym) })
  end
end
