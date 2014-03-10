class UnsubscribesController < ApplicationController
  inherit_resources
  belongs_to :user

  def create
    params[:user][:unsubscribes_attributes].each_value do |subscription|
      if subscription[:subscribed] == '1' && subscription[:id].present? #change from unsubscribed to subscribed
        parent.unsubscribes.where(project_id: subscription[:project_id]).destroy_all
      elsif subscription[:subscribed] == '0' && !subscription[:id].present? #change from subscribed to unsubscribed
        parent.unsubscribes.create!(project_id: subscription[:project_id])
      end
    end
    flash.notice = t('controllers.unsubscribes.create.success')
    return redirect_to settings_user_path(parent)
  end

end
