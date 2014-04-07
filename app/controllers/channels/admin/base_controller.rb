module Channels::Admin
  class BaseController < ApplicationController
    inherit_resources

    before_filter do
      authorize channel, :admin?
    end
  end
end
