class Admin::Channels::OwnersController < Admin::BaseController
  actions :index
  helper_method :parent

  def new; end

  def create
    if params[:user_id].present?
      user = User.find(params[:user_id]) rescue nil

      if user.present?
        if parent.members.include?(user)
          flash[:error] = t('admin.channels.owners.messages.already_a_member')
        else
          parent.members << user
          parent.save
          flash[:success] = t('admin.channels.owners.messages.success')
        end
      else
        flash[:error] = t('admin.channels.owners.messages.user_not_found')
      end
    end

    redirect_to admin_channel_owners_path(parent)
  end

  def destroy
    parent.channel_members.where(user_id: resource.id).first.delete rescue false
    redirect_to admin_channel_owners_path(parent), flash: { success: t('admin.channels.owners.messages.removed') }
  end

  protected
  def resource
    @owner ||= parent.members.find(params[:id])
  end

  def parent
    @channel ||= Channel.find_by_permalink params[:channel_id]
  end

  def collection
    @owners ||= parent.members.page(params[:page])
  end
end
