class DiscoverController < ApplicationController
  def index
    @must_show_all_projects = ActiveRecord::ConnectionAdapters::Column.
      value_to_boolean(params[:show_all_projects]) || params[:search].present?
    @available_states       = Discover::STATES.map do |f|
      [I18n.t("discover.index.states.#{f}"), f]
    end

    discover  = Discover.new(params)
    @projects = discover.projects
    @filters  = discover.filters

    @tags     = Tag.popular
    @channels = Channel.with_state('online').order('RANDOM()').limit(4) unless @filters.any?
  end
end
