class Admin::TagsController < Admin::BaseController
  menu I18n.t("admin.tags.index.menu") => :admin_tags_path
  actions :all, except: [:show]

  def collection
    @tags = apply_scopes(end_of_association_chain).page(params[:page])
  end
end
