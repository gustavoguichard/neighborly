class OmniauthSignIn
  attr_accessor :provider

  delegate :authorization, :user, :existing_user?,
    to: :@user_initializer, allow_nil: true

  def initialize(user, provider)
    @user, @provider = user, provider
  end

  def complete(omniauth_data)
    @user_initializer = UserInitializer.new(omniauth_data)
    @user_initializer.setup
  end
end
