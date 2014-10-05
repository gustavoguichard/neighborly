class Projects::TermsController < ApplicationController
  after_filter :verify_authorized, except: :index
  respond_to :html

  def index
    @project = parent
    @documents = parent.project_documents
  end

  def create
    @document = ProjectDocument.new(permitted_params[:project_document].
                                            merge(project: parent))
    authorize @document
    @document.save
    respond_with @document, location: project_terms_path(parent)
  end

  def destroy
    document = parent.project_documents.find(params[:id])
    authorize document
    document.delete
    respond_with document, location: project_terms_path(parent)
  end

  private

  def parent
    @project = Project.find_by_permalink!(params[:project_id])
  end

  def permitted_params
    params.permit(policy(@document || ProjectDocument).permitted_attributes)
  end
end
