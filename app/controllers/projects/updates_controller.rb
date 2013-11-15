class Projects::UpdatesController < ApplicationController
  inherit_resources
  load_and_authorize_resource

  actions :destroy
  belongs_to :project, finder: :find_by_permalink!

  def index
    if request.xhr? && params[:page] && params[:page].to_i > 1
      render collection
    end
  end

  def create
    @update = parent.updates.create(params[:update].merge!(user: current_user))
    render @update
  end

  def destroy
    destroy! do
      if request.xhr?
        return render nothing: true
      else
        project_updates_path(parent)
      end
    end
  end

  def collection
    @updates ||= end_of_association_chain.visible_to(current_user).order('created_at desc').page(params[:page]).per(3)
  end
end
