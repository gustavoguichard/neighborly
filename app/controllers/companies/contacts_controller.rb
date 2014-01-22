class Companies::ContactsController < ApplicationController
  inherit_resources
  defaults class_name: 'CompanyContact'
  actions :new, :create
end
