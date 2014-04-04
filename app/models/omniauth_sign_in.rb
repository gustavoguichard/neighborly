class OmniauthSignIn
  attr_accessor :provider

  delegate :authorization, :user, :no_account_conflicts?,
    to: :@user_initializer, allow_nil: true

  def initialize(user, provider)
    @user, @provider = user, provider
  end

  def complete(omniauth_data)
    @user_initializer = UserInitializer.new(provider, omniauth_data)
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
