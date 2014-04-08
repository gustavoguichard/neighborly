class Projects::FaqsController < ApplicationController
  after_filter :verify_authorized, except: :index
  inherit_resources
  defaults resource_class: ProjectFaq, collection_name: :project_faqs

  actions :index, :create, :destroy
  belongs_to :project, finder: :find_by_permalink!

  def index
    @project = parent
  end

  def create
    @project_faq = ProjectFaq.new(permitted_params[:project_faq].merge(project: parent))
    authorize @project_faq
    create! { project_faqs_path(parent) }
  end

  def destroy
    authorize resource
    destroy! { project_faqs_path(parent) }
  end

  private
  def permitted_params
    params.permit(policy(@project_faq || ProjectFaq).permitted_attributes)
  end

  def collection
    @faqs ||= end_of_association_chain.order('created_at desc')
  end
end
