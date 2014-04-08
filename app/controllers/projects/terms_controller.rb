class Projects::TermsController < ApplicationController
  after_filter :verify_authorized, except: :index
  inherit_resources
  defaults resource_class: ProjectDocument, collection_name: :project_documents

  actions :create, :destroy
  belongs_to :project, finder: :find_by_permalink!

  def index
    @project = parent
    @documents = parent.project_documents
  end

  def create
    @project_document = ProjectDocument.new(permitted_params[:project_document].
                                            merge(project: parent))
    authorize @project_document
    create! { project_terms_path(parent) }
  end

  def destroy
    authorize resource
    destroy! { project_terms_path(parent) }
  end

  private
  def permitted_params
    params.permit(policy(@project_document || ProjectDocument).permitted_attributes)
  end
end
