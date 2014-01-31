class Admin::TagsController < Admin::BaseController
  actions :all, except: [:show]

  def collection
    @tags ||= apply_scopes(end_of_association_chain).order('created_at desc').page(params[:page])
  end
end
