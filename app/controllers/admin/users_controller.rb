class Admin::UsersController < Admin::BaseController
  inherit_resources
  before_filter :set_title
  before_filter :set_totals

  has_scope :by_id, :by_name, :by_email, :by_payer_email, :by_key, :has_credits, :has_credits_difference, only: :index

  protected
  def set_totals
    totals = end_of_association_chain.contribution_totals
    @total_users = totals[:users].to_i
    @total_contributions = totals[:contributions]
    @total_contributed = totals[:contributed]
    @total_credits = totals[:credits]
  end

  def set_title
    @title = t("admin.users.index.title")
  end

  def collection
    @users ||= apply_scopes(end_of_association_chain).order_by(params[:order_by] || 'coalesce(user_totals.sum, 0) DESC').includes(:user_total).page(params[:page])
  end
end

