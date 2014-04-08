class Projects::UpdatesController < ApplicationController
  after_filter :verify_authorized, except: :index
  inherit_resources
  actions :destroy
  belongs_to :project, finder: :find_by_permalink!

  def index
    @project = parent
    if request.xhr? && params[:page] && params[:page].to_i > 1
      render collection
    end
  end

  def create
    @update = Update.new(permitted_params[:update].
                         merge(project: parent, user: current_user))
    authorize @update
    @update.save
    render @update
  end

  def destroy
    authorize resource
    destroy! do
      if request.xhr?
        return render nothing: true
      else
        project_updates_path(parent)
      end
    end
  end

  private
  def permitted_params
    params.permit(policy(@update || Update).permitted_attributes)
  end

  def collection
    @updates ||= end_of_association_chain.visible_to(current_user).order('created_at desc').page(params[:page]).per(3)
  end
end
