class Projects::FaqsController < ApplicationController
  inherit_resources
  defaults resource_class: ProjectFaq, collection_name: :project_faqs
  load_and_authorize_resource class: :ProjectFaq

  actions :index, :create, :destroy
  belongs_to :project, finder: :find_by_permalink!

  def index
    @project = parent
  end

  def create
    create! { project_faqs_path(parent) }
  end

  def destroy
    destroy! { project_faqs_path(parent) }
  end

  def collection
    @faqs ||= end_of_association_chain.order('created_at desc')
  end
end
