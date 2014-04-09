# coding: utf-8
class UsersController < ApplicationController
  after_filter :verify_authorized, except: :show

  inherit_resources
  actions :show, :edit, :update
  respond_to :html, :json

  def show
    return redirect_to root_url(subdomain: resource.channel.permalink) if resource.channel? && resource.channel.present?
    show!{
      fb_admins_add(@user.facebook_id) if @user.facebook_id
      @title = "#{@user.display_name}"
    }
  end

  def edit
    authorize resource
    @user.build_organization unless @user.organization
    render :profile if request.xhr?
  end

  def credits
    authorize resource
    @title = "Credits: #{@user.display_name}"
    @credits = @user.contributions.can_refund
  end

  def payments
    authorize resource
  end

  def settings
    authorize resource
    @title = "Settings: #{@user.display_name}"
    @subscribed_to_updates = @user.updates_subscription
    @unsubscribes = @user.project_unsubscribes
  end

  def set_email
    authorize current_user || User.new
    @user = current_user
    render layout: 'devise'
  end

  def update_email
    authorize resource
    update! do |success,failure|
      success.html do
        flash.notice = t('devise.confirmations.send_instructions')
        sign_out current_user
        redirect_to root_path
      end
      failure.html do
        flash.notice = @user.errors[:email].to_sentence if @user.errors[:email].present?
        return render :set_email, layout: 'devise'
      end
    end
  end

  def update
    authorize resource
    update! do |success,failure|
      success.html do
        flash.notice = update_success_flash_message
        return redirect_to settings_user_path(@user) if params[:settings]
        return redirect_to edit_user_path(@user)
      end
      failure.html do
        flash.alert = @user.errors.full_messages.to_sentence
        return redirect_to settings_user_path(@user) if params[:settings]
        @user.build_organization unless @user.organization
        return render 'edit'
      end
      success.json do
        return render json: { status: :success, uploaded_image: @user.uploaded_image_url(:thumb_avatar), :"organization_attributes[image]" => (@user.organization.image_url(:thumb) rescue nil ) }
      end
      failure.json do
        return render json: { status: :error }
      end
    end
  end

  def update_password
    authorize resource
    if @user.update_with_password(permitted_params[:user])
      flash.notice = t('controllers.users.update.success')
    else
      flash.alert  = @user.errors.full_messages.to_sentence
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

  def permitted_params
    params.permit(policy(@user || User).permitted_attributes)
  end
end
