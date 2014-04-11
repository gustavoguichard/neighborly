# coding: utf-8
class ApplicationController < ActionController::Base
  include Concerns::ExceptionHandler
  include Concerns::SocialHelpersHandler
  include Concerns::PersistentWarnings
  include Pundit

  protect_from_forgery
  before_filter :require_basic_auth

  before_filter :set_return_to, if: -> { !current_user && params[:redirect_to].present? }
  before_filter :redirect_user_back_after_login, unless: :devise_controller?
  before_filter :configure_permitted_parameters, if: :devise_controller?
  helper_method :channel, :referal_link

  before_filter :force_http
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
  def set_return_to
    if params[:redirect_to].present?
      session[:return_to] = params[:redirect_to]
      flash[:devise_error] = t('devise.failure.unauthenticated')
    end
  end

  def referal_it!
    session[:referal_link] = params[:ref] if params[:ref].present?
  end

  def after_sign_in_path_for(resource_or_scope)
    return_to = session[:return_to]
    session[:return_to] = nil
    (return_to || root_path)
  end

  def force_http
    redirect_to(protocol: 'http', host: ::Configuration[:base_domain]) if request.ssl?
  end

  def redirect_user_back_after_login
    if request.env['REQUEST_URI'].present? && !request.xhr?
      session[:return_to] = request.env['REQUEST_URI']
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:name, :email, :password, :newsletter)
    end
  end

  def require_basic_auth
    black_list = ['neighborly-staging.herokuapp.com', 'staging.neighbor.ly', 'channel.staging.neighbor.ly', 'kaboom.neighbor.ly', 'cfg.neighbor.ly', 'makeitright.neighbor.ly']

    if request.url.match Regexp.new(black_list.join("|"))
      authenticate_or_request_with_http_basic do |username, password|
        username == 'admin' && password == 'Streetcar4321'
      end
    end
  end
end
