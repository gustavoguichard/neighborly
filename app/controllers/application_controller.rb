# coding: utf-8
require 'uservoice_sso'
class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :require_basic_auth

  before_filter :redirect_user_back_after_login, unless: :devise_controller?
  before_filter :configure_permitted_parameters, if: :devise_controller?

  rescue_from ActionController::RoutingError, with: :render_404
  rescue_from ActionController::UnknownController, with: :render_404
  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  rescue_from CanCan::Unauthorized do |exception|
    session[:return_to] = request.env['REQUEST_URI']
    message = exception.message

    if current_user.nil?
      redirect_to new_user_session_path, alert: I18n.t('devise.failure.unauthenticated')
    elsif request.env["HTTP_REFERER"]
      redirect_to :back, alert: message
    else
      redirect_to root_path, alert: message
    end
  end

  helper_method :namespace, :fb_admins, :render_facebook_sdk, :render_facebook_like, :render_twitter, :display_uservoice_sso, :total_with_fee

  before_filter :force_http


  before_filter do
    if current_user and current_user.email == "change-your-email+#{current_user.id}@neighbor.ly"
      redirect_to set_email_users_path unless controller_name == 'users'
    end
  end

  # TODO: Change this way to get the opendata
  before_filter do
    @fb_admins = [100000428222603, 547955110]
  end

  # TODO: REFACTOR
  include ActionView::Helpers::NumberHelper
  def total_with_fee(backer, payment_method)
    if payment_method == 'paypal'
      value = (backer.value * 1.029)+0.30
    elsif payment_method == 'credit_card_net'
      value = (backer.value * 1.029)+0.30
    elsif payment_method == 'echeck_net'
      value = (backer.value * 1.010)+0.30
    else
      value = backer.value
    end
    number_to_currency value, :unit => "$", :precision => 2, :delimiter => ','
  end

  # We use this method only to make stubing easier
  # and remove FB templates from acceptance tests
  def render_facebook_sdk
    render_to_string(partial: 'layouts/facebook_sdk').html_safe
  end

  def render_twitter options={}
    render_to_string(partial: 'layouts/twitter', locals: options).html_safe
  end

  def render_facebook_like options={}
    render_to_string(partial: 'layouts/facebook_like', locals: options).html_safe
  end

  def display_uservoice_sso
    if current_user && ::Configuration[:uservoice_subdomain] && ::Configuration[:uservoice_sso_key]
      Uservoice::Token.generate({
        guid: current_user.id, email: current_user.email, display_name: current_user.display_name,
        url: user_url(current_user), avatar_url: current_user.display_image
      })
    end
  end

  private
  def fb_admins
    @fb_admins.join(',')
  end

  def fb_admins_add(ids)
    case ids.class
    when Array
      ids.each {|id| @fb_admins << ids.to_i}
    else
      @fb_admins << ids.to_i
    end
  end

  def namespace
    names = self.class.to_s.split('::')
    return "null" if names.length < 2
    names[0..(names.length-2)].map(&:downcase).join('_')
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def after_sign_in_path_for(resource_or_scope)
    if current_user and current_user.email == "change-your-email+#{current_user.id}@neighbor.ly"
      return set_email_users_path
    end

    return_to = session[:return_to]
    session[:return_to] = nil
    (return_to || root_path)
  end

  def render_404(exception)
    @not_found_path = exception.message
    respond_to do |format|
      format.html { render template: 'static/404', status: 404 }
      format.all { render nothing: true, status: 404 }
    end
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
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:name,
                                                            :email,
                                                            :password) }
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
