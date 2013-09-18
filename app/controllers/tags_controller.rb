class TagsController < ApplicationController
  def index
    render json: Tag.where('name ~ ?', params[:term]).map { |t| { id: t.name, value: t.name, label: t.name } }
  end
end
