class ApplicationController < ActionController::Base
  include Concerns::ExceptionHandler
  include Concerns::SocialHelpersHandler
  include Concerns::PersistentWarnings
  include Concerns::AuthenticationHandler
  include Pundit

  protect_from_forgery

  helper_method :channel, :referral_url
  before_action :referral_it!

  before_filter do
    if current_user and (current_user.email =~ /change-your-email\+[0-9]+@neighbor\.ly/)
      redirect_to set_email_users_path unless controller_name =~ /users|confirmations/
    end
  end

  def channel
    Channel.find_by_permalink(request.subdomain.to_s)
  end

  def referral_url
    session[:referral_url]
  end

  private

  def referral_it!
    session[:referral_url] = params[:ref] if params[:ref].present?
  end
end
