class DiscoverController < ApplicationController
  def index
    authorize Project, :discover?
    @presenter = DiscoverPresenter.new(params)
  end
end
