class Users::ContributionsController < ApplicationController
  after_filter :verify_authorized, except: :index
  after_filter :verify_policy_scoped, only: :index
  inherit_resources
  defaults resource_class: Contribution
  belongs_to :user
  actions :index

  def index
    authorize parent, :update?
    index!
  end

  protected
  def policy_scope(scope)
    @_policy_scoped = true
    ContributionPolicy::UserScope.new(current_user, parent, scope).resolve
  end

  def collection
    @contributions ||= policy_scope(end_of_association_chain).
      order("created_at DESC, confirmed_at DESC").
      includes(:user, :reward, project: [:user]).
      page(params[:page]).per(10)
  end
end
