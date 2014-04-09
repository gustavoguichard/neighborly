module Concerns
  module ExceptionHandler
    extend ActiveSupport::Concern

    included do
      rescue_from ActionController::RoutingError,       with: :render_404
      rescue_from ActionController::UnknownController,  with: :render_404
      rescue_from ActiveRecord::RecordNotFound,         with: :render_404

      rescue_from Pundit::NotAuthorizedError,  with: :deny_access
    end

    def deny_access(exception)
      session[:return_to] = request.env['REQUEST_URI']

      # Clear the previous response body to avoid a DoubleRenderError
      # when redirecting or rendering another view
      self.response_body = nil

      if current_user.nil?
        redirect_to main_app.new_user_session_path, alert: I18n.t('devise.failure.unauthenticated')
      elsif request.env['HTTP_REFERER']
        redirect_to :back, alert: I18n.t('controllers.unauthorized')
      else
        redirect_to main_app.root_path, alert: I18n.t('controllers.unauthorized')
      end
    end

    def render_404(exception)
      @not_found_path = exception.message
      respond_to do |format|
        format.html { render template: 'errors/not_found', status: 404 }
        format.all { render nothing: true, status: 404 }
      end
    end

  end
end
