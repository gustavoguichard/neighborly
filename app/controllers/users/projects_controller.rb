class Users::ProjectsController < ApplicationController
  inherit_resources
  actions :index
  belongs_to :user

  def index
    authorize parent, :update?
    index!
  end

  def collection
    @projects ||= end_of_association_chain
  end
end
