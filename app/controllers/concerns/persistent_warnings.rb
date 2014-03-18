module Concerns
  module PersistentWarnings
    extend ActiveSupport::Concern

    included do
      before_action :set_persistent_warning, unless: -> { request.xhr? }
    end

    def set_persistent_warning
      current_warning = persistent_warning
      flash.notice = current_warning if current_warning
    end

    def persistent_warning
      [
        confirm_account,
        complete_profile
      ].detect do |possible_warnings|
        !possible_warnings.nil?
      end
    end

    protected

    def confirm_account
      if user_signed_in? && !current_user.confirmed?
        { message:     t('devise.confirmations.confirm',
                         link: new_user_confirmation_path),
          dismissible: false }
      end
    end

    def complete_profile
      if user_signed_in? && current_user.completeness_progress.to_i < 100
        { message: t('controllers.users.completeness_progress',
                     link: edit_user_path(current_user)),
          dismissible: false }
      end
    end
  end
end
