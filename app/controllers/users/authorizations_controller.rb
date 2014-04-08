class Users::AuthorizationsController < ApplicationController
  inherit_resources
  belongs_to :user
  actions :destroy

  def destroy
    authorize resource
    destroy! do |format|
      format.html { redirect_to edit_user_path(parent) }
    end
  end
end
