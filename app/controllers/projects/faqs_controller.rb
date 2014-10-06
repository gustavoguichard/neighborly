class Projects::FaqsController < ApplicationController
  after_filter :verify_authorized, except: :index
  respond_to :html

  def index
    @project = parent
    @faqs = parent.project_faqs.to_a
  end

  def create
    @faq = ProjectFaq.new(permitted_params[:project_faq].merge(project: parent))
    authorize @faq
    @faq.save
    respond_with @faq, location: project_faqs_path(parent)
  end

  def destroy
    @faq = parent.project_faqs.find(params[:id])
    authorize @faq
    @faq.delete
    respond_with @faq, location: project_faqs_path(parent)
  end

  private

  def parent
    @project ||= Project.find_by_permalink!(params[:project_id])
  end

  def permitted_params
    params.permit(policy(@faq || ProjectFaq).permitted_attributes)
  end

  def collection
    @faqs ||= end_of_association_chain.order('created_at desc')
  end
end
