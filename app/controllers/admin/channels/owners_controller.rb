class Admin::Channels::OwnersController < Admin::BaseController
  actions :index
  helper_method :parent

  def new; end

  def create
    if params[:user_id].present?
      user = User.find(params[:user_id]) rescue nil

      if user.present?
        if user.channel_id.present?
          flash[:error] = t('admin.channels.owners.messages.owns_a_channel')
        else
          user.update_attribute(:channel_id, parent.id)
          flash[:success] = t('admin.channels.owners.messages.success')
        end
      else
        flash[:error] = t('admin.channels.owners.messages.user_not_found')
      end
    end

    redirect_to admin_channel_owners_path(parent)
  end

  def destroy
    resource.update_attribute(:channel_id, nil)
    redirect_to admin_channel_owners_path(parent), flash: { success: t('admin.channels.owners.messages.removed') }
  end

  protected
  def resource
    @owner ||= parent.users.find(params[:id])
  end

  def parent
    @channel ||= Channel.find_by_permalink params[:channel_id]
  end

  def collection
    @owners ||= parent.users.page(params[:page])
  end
end
