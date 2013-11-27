class Admin::PressAssetsController < Admin::BaseController
  actions :all, except: [:show]
  menu I18n.t("admin.press_assets.index.menu") => :admin_press_assets_path

  def collection
    @press_assets = apply_scopes(end_of_association_chain).page(params[:page])
  end
end
