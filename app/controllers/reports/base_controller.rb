class Reports::BaseController < ApplicationController
  inherit_resources
  respond_to :csv
  actions :index
end
