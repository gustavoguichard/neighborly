class BrokerageAccountsController < ApplicationController
  before_action :store_contribution_id, only: %i(new edit)
  after_action :alert_broker, only: %i(create update)

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
    @after_save_url ||= if session[:contribution_id]
      route_params = {
        project_id: contribution.project.permalink,
        id:         session[:contribution_id]
      }
      main_app.project_contribution_url(route_params)
    else
      root_path
    end
  end

  # Tries to store the referrer, checking if the user comes from a contribution action.
  # No implementation intended from others.
  def store_contribution_id
    begin
      session[:contribution_id] =
        Rails.application.routes.recognize_path(request.referer)[:id]
    rescue ActionController::RoutingError; end
  end

  def alert_broker
    if session[:contribution_id] && @brokerage_account.valid?
      contribution.wait_broker
    end
  end

  def contribution
    @contribution ||= Contribution.find(session[:contribution_id])
  end
end
