class ConfirmationsController < Devise::ConfirmationsController
  def show
    confirmation_token = Devise.token_generator.
      digest(self, :confirmation_token, token_param)
    self.resource = resource_class.
      find_by(confirmation_token: confirmation_token)

    super unless resource
  end

  def confirm
    self.resource = resource_class.find_by(confirmation_token: token_param)
    resource.assign_attributes(permitted_params)
    resource.confirmed_at = Time.now.utc

    if resource.valid?
      resource.confirm!
      set_flash_message :notice, :confirmed
      sign_in resource, bypass: true
      redirect_to after_sign_in_path_for(:user)
    else
      render 'show'
    end
  end

  private

  def permitted_params
    params.require(resource_name).permit(
      :name,
      :confirmation_token,
      :password,
      :password_confirmation
    )
  end

  def token_param
    params[:confirmation_token] ||
      params[resource_name].try(:[], :confirmation_token)
  end
end
