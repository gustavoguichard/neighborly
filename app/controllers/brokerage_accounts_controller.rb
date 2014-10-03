class BrokerageAccountsController < ApplicationController
  before_action :store_after_save_url, only: %i(new edit)

  def new
    @brokerage_account = current_user.build_brokerage_account
    authorize @brokerage_account
    @brokerage_account.name    = current_user.name
    @brokerage_account.address = current_user.address_street
    @brokerage_account.email   = current_user.email
    @brokerage_account.phone   = current_user.phone_number
  end

  def create
    @brokerage_account = current_user.
      build_brokerage_account(permitted_params[:brokerage_account])
    authorize @brokerage_account

    if @brokerage_account.save
      redirect_to after_save_url
    else
      render 'new'
    end
  end

  def edit
    @brokerage_account = current_user.brokerage_account
    authorize @brokerage_account

    render 'new'
  end

  def update
    @brokerage_account = current_user.brokerage_account
    authorize @brokerage_account

    if @brokerage_account.update_attributes(permitted_params[:brokerage_account])
      redirect_to after_save_url
    else
      render 'new'
    end
  end

  private

  def permitted_params
    attributes = policy(
      @brokerage_account || BrokerageAccount
    ).permitted_attributes

    params.permit(attributes)
  end

  def after_save_url
    @after_save_url ||= session.delete(:after_brokerage_url) || root_path
  end

  # Tries to store the referrer, checking if the user comes from a contribution action.
  # No implementation intended from others.
  def store_after_save_url
    begin
      referer_params =
        Rails.application.routes.recognize_path(request.referer).slice(:project_id, :id)
      session[:after_brokerage_url] =
        main_app.project_contribution_url(referer_params)
    rescue ActionController::RoutingError; end
  end
end
