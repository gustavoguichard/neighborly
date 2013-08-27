class  CatarseEcheckNet::EcheckNetController < ApplicationController
  skip_before_filter :force_http
  layout :false

  def review
  end
end
