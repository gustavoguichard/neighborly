class ImagesController < ApplicationController
  before_filter :authenticate_user!

  def new
    render layout: !request.xhr?
  end

  def create
    @image = Image.new(permitted_params[:image].merge!(user: current_user))
    if @image.save
        render json: {
          status: :success,
          :"image[file]" => @image.file_url(:medium)
        }
    else
      return render json: { status: :error }
    end
  end

  protected
  def permitted_params
    params.permit(image: [:file])
  end
end
