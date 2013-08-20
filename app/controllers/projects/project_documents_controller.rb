class Projects::ProjectDocumentsController < ApplicationController
  inherit_resources
  load_and_authorize_resource

  actions :index, :create, :destroy
  belongs_to :project

  def create
    create! { project_by_slug_path(parent.permalink, anchor: 'terms') }
  end

  def destroy
    destroy! { project_by_slug_path(parent.permalink, anchor: 'terms') }
  end
end
