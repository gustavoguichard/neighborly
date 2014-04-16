class ApplicationController < ActionController::Base
  include Concerns::ExceptionHandler
  include Concerns::SocialHelpersHandler
  include Concerns::PersistentWarnings
  include Concerns::AuthenticationHandler
  include Pundit

  force_ssl if: :use_ssl?
  protect_from_forgery

  helper_method :channel, :referal_link
  before_action :referal_it!

  before_filter do
    if current_user and (current_user.email =~ /change-your-email\+[0-9]+@neighbor\.ly/)
      redirect_to set_email_users_path unless controller_name =~ /users|confirmations/
    end
  end

  def channel
    Channel.find_by_permalink(request.subdomain.to_s)
  end

  def referal_link
    session[:referal_link]
  end

  private
  def use_ssl?
    Rails.env.production? && !request.subdomain.present?
  end

  def referal_it!
    session[:referal_link] = params[:ref] if params[:ref].present?
  end
end
