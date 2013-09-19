class Adm::TagsController < Adm::BaseController
  menu I18n.t("adm.tags.index.menu") => Rails.application.routes.url_helpers.adm_tags_path
  actions :all, except: [:show]

  def collection
    @tags = apply_scopes(end_of_association_chain).page(params[:page])
  end
end
