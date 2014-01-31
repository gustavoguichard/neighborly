class Companies::ContactsController < ApplicationController
  inherit_resources
  defaults class_name: 'CompanyContact'
  actions :new, :create

  def create
    create! do
      flash[:success] = { message: t('controllers.companies.contacts.create.success'), dismissible: false }
      return redirect_to companies_contact_path
    end
  end
end
