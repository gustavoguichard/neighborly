# coding: utf-8
class UsersController < ApplicationController
  after_filter :verify_authorized, except: [:show, :my_spot]
  before_action :authenticate_user!, only: :my_spot

  def show
    @user = resource
    @projects = Project.contributed_by(@user).
      includes(:contributions, :project_total)
    set_facebook_url_admin(@user)
    @title = "#{@user.display_name}"
  end

  def edit
    authorize resource
    @user.build_organization unless @user.organization
    render :profile if request.xhr?
  end

  def payments
    authorize resource
  end

  def settings
    authorize resource
    @title = "Settings: #{@user.display_name}"
  end

  def set_email
    authorize current_user || User.new
    @user = current_user
    render layout: 'devise'
  end

  def update_email
    authorize resource
    resource.update(permitted_params[:user])

    respond_to do |format|
      if resource.save
        format.html do
          flash.notice = t('devise.confirmations.send_instructions')
          sign_out current_user
          redirect_to root_path
        end
      else
        format.html do
          flash.notice = @user.errors[:email].to_sentence if @user.errors[:email].present?
          return render :set_email, layout: 'devise'
        end
      end
    end
  end

  def update
    authorize resource
    resource.update(permitted_params[:user])

    respond_to do |format|
      if resource.save
        format.html do
          flash.notice = update_success_flash_message unless params[:investment_prospect]
          return redirect_to settings_user_path(@user) if params[:settings]
          if params[:investment_prospect]
            flash.delete(:notice)
            return redirect_to root_path
          end
          return redirect_to edit_user_path(@user)
        end

        format.json do
          return render json: { status: :success, uploaded_image: @user.uploaded_image_url(:thumb_avatar), :"organization_attributes[image]" => (@user.organization.image_url(:thumb) rescue nil ) }
        end
      else
        format.html do
          flash.alert = @user.errors.full_messages.to_sentence
          return redirect_to settings_user_path(@user) if params[:settings]
          @user.build_organization unless @user.organization
          return render 'edit'
        end

        format.json do
          return render json: { status: :error }
        end
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

  def my_spot; end

  def validate_access_code
    user = User.find(params[:user_id])
    authorize user
    access_code = AccessCode.find_by(code: params[:code])
    if access_code
      if access_code.still_valid?
        user.update_attributes(beta: true, access_code: access_code)
        flash.notice = 'Access Code Accepted. Welcome to the beta!'
        redirect_to root_path
      else
        flash.alert = 'This access code is not valid anymore.'
      redirect_to user_my_spot_path(user)
      end
    else
      flash.alert = 'Access Code Not Found'
      redirect_to user_my_spot_path(user)
    end
  end

  private

  def resource
    @user ||= User.find(params[:id])
  end

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
