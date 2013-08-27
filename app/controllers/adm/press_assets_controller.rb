class Adm::PressAssetsController < Adm::BaseController
  actions :all, except: [:show]
  menu I18n.t("adm.press_assets.index.menu") => Rails.application.routes.url_helpers.adm_press_assets_path

  def collection
    @press_assets = apply_scopes(end_of_association_chain).page(params[:page])
  end
end
