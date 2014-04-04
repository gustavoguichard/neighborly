class ImagesController < ApplicationController
  before_filter :authenticate_user!
  inherit_resources
  actions :create

  respond_to :html, :json

  def new
    render layout: !request.xhr?
  end

  def create
    @image = Image.new(permitted_params[:image].merge!(user: current_user))

    create! do |success, failure|
      success.json do
        return render json: { status: :success,
                              :"image[file]" => @image.file_url }
      end

      failure.json do
        return render json: { status: :error }
      end
    end
  end

  protected
  def permitted_params
    params.permit(image: [:file])
  end
end
