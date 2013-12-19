class Users::AuthorizationsController < ApplicationController
  load_and_authorize_resource
  inherit_resources
  belongs_to :user
  actions :destroy

  def destroy
    destroy! do |format|
      format.html { redirect_to edit_user_path(parent) }
    end
  end
end
