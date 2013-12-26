# coding: utf-8
class UsersController < ApplicationController
  load_and_authorize_resource new: [ :set_email ]
  inherit_resources
  actions :show, :edit, :update, :unsubscribe_update, :set_email, :update_email
  respond_to :html, :json

  def show
    return redirect_to root_url(subdomain: resource.channel.permalink) if resource.channel? && resource.channel.present?
    show!{
      fb_admins_add(@user.facebook_id) if @user.facebook_id
      @title = "#{@user.display_name}"
    }
  end

  def edit
    @user.build_organization unless @user.organization
    render :profile if request.xhr?
  end

  def credits
    @title = "Credits: #{@user.display_name}"
    @user = User.find params[:id]
    @credits = @user.backs.can_refund
  end

  def settings
    @title = "Settings: #{@user.display_name}"
    @user = User.find params[:id]
    @subscribed_to_updates = @user.updates_subscription
    @unsubscribes = @user.project_unsubscribes
  end

  def set_email
    @user = current_user
    render layout: 'devise'
  end

  def update_email
    update! do |success,failure|
      success.html do
        flash[:notice] = t('devise.confirmations.send_instructions')
        sign_out current_user
        redirect_to root_path
      end
      failure.html do
        flash[:notice] = @user.errors[:email].to_sentence if @user.errors[:email].present?
        return render :set_email, layout: 'devise'
      end
    end
  end

  def update
    update! do |success,failure|
      success.html do
        flash[:notice] = update_success_flash_message
      end
      failure.html do
        flash[:error] = @user.errors.full_messages.to_sentence
      end
      success.json do
        return render json: { status: :success, hero_image: @user.hero_image_url(:blur), uploaded_image: @user.uploaded_image_url(:thumb_avatar), :"organization_attributes[image]" => (@user.organization.image_url(:thumb) rescue nil ) }
      end
      failure.json do
        return render json: { status: :error }
      end
    end
    return redirect_to params[:settings] ? settings_user_path(@user) : edit_user_path(@user)
  end

  def update_password
    @user = User.find(params[:id])
    if @user.update_with_password(params[:user])
      flash[:notice] = t('controllers.users.update.success')
    else
      flash[:error] = @user.errors.full_messages.to_sentence
    end
    return redirect_to settings_user_path(@user)
  end

  protected
  def update_success_flash_message
    if (params['user']['email'] != @user.email rescue false) && params['user']['email'].present?
      t('devise.confirmations.send_instructions')
    else
      t('controllers.users.update.success')
    end
  end
end
