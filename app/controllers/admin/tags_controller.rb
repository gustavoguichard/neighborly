class Admin::TagsController < Admin::BaseController
  actions :all, except: [:show]

  def collection
    @tags ||= apply_scopes(end_of_association_chain).page(params[:page])
  end
end
