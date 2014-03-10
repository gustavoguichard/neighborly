class Admin::ChannelsController < Admin::BaseController
  defaults finder: :find_by_permalink
  actions :all, except: [:show]

  def self.channel_actions
    %w[push_to_draft push_to_online].each do |action|
      define_method action do
        resource.send(action)
        flash.notice = I18n.t("admin.channels.messages.successful.#{action}")
        redirect_to admin_channels_path(params[:local_params])
      end
    end
  end
  channel_actions

  protected
  def collection
    @channels = apply_scopes(end_of_association_chain).order(:name).page(params[:page])
  end
end
