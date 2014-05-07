class Channels::ChannelsSubscribersController < Channels::BaseController
  after_filter :verify_authorized, except: :create
  inherit_resources
  actions :show, :destroy, :create

  # We use show as create to redirect to this action after auth
  def show
    @channels_subscriber = ChannelsSubscriber.new subscription_attributes
    authorize @channels_subscriber
    create! do |format|
      flash.notice = I18n.t('controllers.channels_subscribers.created', channel: channel.name)
      return redirect_to root_path
    end
  end

  def destroy
    authorize resource
    destroy! do |format|
      flash.notice = I18n.t('controllers.channels_subscribers.deleted', channel: channel.name)
      return redirect_to root_path
    end
  end

  def resource
    @channels_subscriber ||= ChannelsSubscriber.where(subscription_attributes).first!
  end

  private
  def subscription_attributes
    { channel_id: channel.id, user_id: current_user.try(:id) }
  end
end
