class OmniauthSignIn
  attr_accessor :current_user, :data

  delegate :user, :provider_name, :already_signed_in?, :authorization_exists?, :empty_email?,
    to: :@user_initializer, allow_nil: true

  def initialize(current_user)
    @current_user = current_user
  end

  def complete(omniauth_data, new_omniauth_data = {})
    @data             = omniauth_data
    @user_initializer = UserInitializer.new(@data, @current_user)
    @user_initializer.setup
    if signed_in? && new_omniauth_data.present?
      @user_initializer = UserInitializer.new(new_omniauth_data, @user_initializer.user)
      @user_initializer.attach_authorization
    end
  end

  def status
    if already_signed_in? || authorization_exists?
      :success
    elsif empty_email?
      :needs_email
    else
      :needs_ownership_confirmation
    end
  end

  def signed_in?
    status.eql? :success
  end
end
