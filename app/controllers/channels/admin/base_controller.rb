class Channels::Admin::BaseController < ApplicationController
  inherit_resources

  before_filter do
    authorize channel, :admin?
  end
end
