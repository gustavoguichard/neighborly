class OmniauthSignIn
  attr_accessor :current_user, :data

  delegate :user, :provider, :already_signed_in?, :authorization_exists?, :empty_email?,
    to: :@user_initializer, allow_nil: true

  def initialize(current_user)
    @current_user = current_user
  end

  def complete(omniauth_data)
    @data             = omniauth_data
    @user_initializer = UserInitializer.new(@data, @current_user)
    @user_initializer.setup
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
end
