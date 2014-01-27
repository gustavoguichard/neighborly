class Users::ContributionsController < ApplicationController
  inherit_resources
  defaults resource_class: Contribution
  belongs_to :user
  actions :index

  def request_refund
    authorize! :request_refund, resource
    if resource.value > resource.user.user_total.credits
      flash[:failure] = I18n.t('controllers.users.contributions.request_refund.insufficient_credits')
    elsif can?(:request_refund, resource) && resource.can_request_refund?
      resource.request_refund!
      flash[:notice] = I18n.t('controllers.users.contributions.request_refund.refunded')
    end

    redirect_to credits_user_path(parent)
  end

  protected
  def collection
    @contributions ||= end_of_association_chain.available_to_display.order("created_at DESC, confirmed_at DESC")
    @contributions = @contributions.not_anonymous.with_state('confirmed') unless can? :manage, @user
    @contributions = @contributions.includes(:user, :reward, project: [:user, :category, :project_total])
  end
end
