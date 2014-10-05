class Users::ContributionsController < ApplicationController
  after_filter :verify_authorized, except: :index
  after_filter :verify_policy_scoped, only: :index

  def index
    authorize parent, :update?
    @contributions = policy_scope(parent.contributions).
      order("created_at DESC").
      includes(:reward, :project)
  end

  private

  def policy_scope(scope)
    @_policy_scoped = true
    ContributionPolicy::UserScope.new(current_user, parent, scope).resolve
  end

  def parent
    @user ||= User.find(params[:user_id])
  end
end
