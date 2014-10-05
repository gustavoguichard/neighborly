class Users::AuthorizationsController < ApplicationController
  respond_to :html

  def destroy
    authorization = parent.authorizations.find(params[:id])
    authorize authorization
    authorization.delete
    respond_with authorization, location: edit_user_path(parent)
  end

  private

  def parent
    @user ||= User.find(params[:user_id])
  end
end
