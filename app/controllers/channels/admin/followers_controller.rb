class Channels::Admin::FollowersController < Admin::BaseController
  add_to_menu 'channels.admin.followers.menu', :channels_admin_followers_path
  actions :index

  before_filter do
    @channel = Channel.find_by_permalink!(request.subdomain.to_s)
  end

  def index
    @total_subscribers = @channel.subscribers.count
  end
end
