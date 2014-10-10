class ApplicationController < ActionController::Base
  include Concerns::ExceptionHandler
  include Concerns::SocialHelpersHandler
  include Concerns::PersistentWarnings
  include Concerns::AuthenticationHandler
  include Pundit

  protect_from_forgery

  before_action :initialize_analytics, :store_referral_code

  before_filter do
    if current_user and (current_user.email =~ /change-your-email\+[0-9]+@neighbor\.ly/)
      redirect_to set_email_users_path unless controller_name =~ /users|confirmations/
    end
  end

  def referral_code
    session[:referral_code]
  end

  private

  def initialize_analytics
    user_level = if current_user
      if current_user.admin
        'Administrator'
      elsif current_user.beta
        'MVP Beta User'
      else
        'Normal user'
      end
    else
      'Anonymous'
    end

    @analytics = {
      user_level: user_level
    }
  end

  def store_referral_code
    session[:referral_code] ||= params[:ref]
  end
end
