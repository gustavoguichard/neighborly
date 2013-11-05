class DiscoverController < ApplicationController
  def index
    @title = t('explore.title')
    ## Just to know if we should present the menu entries, the actual projects are fetched via AJAX
    #@recommended = Project.not_soon.visible.not_expired.recommended.limit(1)
    #@expiring = Project.not_soon.visible.expiring.limit(1)
    #@recent = Project.not_soon.visible.recent.not_expired.limit(1).order('created_at DESC')
    #@successful = Project.not_soon.visible.successful.limit(1)
    #@soon = Project.soon.visible.limit(1)
    @categories = Category.with_projects.order(:name_pt)
  end
end
