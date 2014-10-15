class SessionsController < Devise::SessionsController
  include OmniauthAuthenticationControllerHelpers

  after_filter :attach_omniauth_authorization,
    only: :create,
    if: -> { session.has_key?(:new_user_attrs) }

  def new
    response.headers['X-Csrf-Token'] = form_authenticity_token
    super
  end

  def set_new_user_email
    @form_submition = {
      url:         confirm_new_user_email_path,
      method:      :patch,
      submit_text: t('submit', scope: 'sessions.set_new_user_email')
    }

    render 'users/set_email'
  end

  def confirm_new_user_email
    session[:new_user_attrs]       ||= {}
    session[:new_user_attrs][:email] = params.fetch(:user).fetch(:email)

    complete_request_with(attach_omniauth_authorization)
  end

  protected

  def attach_omniauth_authorization
    omniauth_sign_in = OmniauthSignIn.new(current_user)
    omniauth_sign_in.complete(session.delete(:new_user_attrs))
    omniauth_sign_in
  end
end
