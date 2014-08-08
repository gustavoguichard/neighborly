class DiscoverController < ApplicationController
  def index
    @presenter = DiscoverPresenter.new(params)
  end
end
