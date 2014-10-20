module Concerns
  module SocialHelpersHandler
    extend ActiveSupport::Concern

    # We use this method only to make stubing easier
    # and remove FB templates from acceptance tests
    included do
      helper_method :facebook_url_admin,
                    :render_facebook_sdk,
                    :render_facebook_like,
                    :render_twitter
    end

    def facebook_url_admin
      @facebook_url_admin.to_s
    end

    def set_facebook_url_admin(user)
      @facebook_url_admin = user.facebook_id
    end

    def render_facebook_sdk
      render_to_string(partial: 'layouts/facebook_sdk').html_safe
    end

    def render_twitter options={}
      render_to_string(partial: 'layouts/twitter', locals: options).html_safe
    end

    def render_facebook_like options={}
      render_to_string(partial: 'layouts/facebook_like', locals: options).html_safe
    end
  end
end
