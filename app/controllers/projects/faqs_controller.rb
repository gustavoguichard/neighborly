class Projects::FaqsController < ApplicationController
  inherit_resources
  defaults resource_class: ProjectFaq
  load_and_authorize_resource :project_faq

  actions :index, :create, :destroy
  belongs_to :project, finder: :find_by_permalink!

  def create
    create! { project_faqs_path(parent) }
  end

  def destroy
    destroy! { project_faqs_path(parent) }
  end
end
