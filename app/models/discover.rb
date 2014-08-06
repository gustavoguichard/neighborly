class Discover
  attr_accessor :filters, :params

  FILTERS = %w(state near category tags search)
  STATES  = %w(active recommended expiring recent successful soon with_active_matches)

  def initialize(params)
    @projects = Project.visible
    @filters  = {}
    @params = params
  end

  def projects
    params.compact.slice(*FILTERS).each do |scope, value|
      send(scope, value)
    end

    @projects = @projects.group('projects.id') unless params[:search].present?
    @projects.order_for_search
  end

  private

  def state(value)
    return unless STATES.include?(value.downcase)
    @projects = @projects.send(value.downcase)
    filters.merge! state: value.downcase
  end

  def near(value)
    @projects = @projects.near(value, 30)
    filters.merge! near: value
  end

  def category(value)
    category = Category.where('name_en ILIKE ?', value).first
    if category.present?
      @projects = @projects.where(category_id: category.id)
      filters.merge! category: category.to_s
    end
  end

  def tags(value)
    tags = Project::TagList.new value
    @projects = @projects.joins("JOIN taggings ON taggings.project_id = projects.id AND taggings.tag_id IN (SELECT id FROM tags WHERE tags.name IN (#{tags.map { |t| "'#{t}'"}.join(',')}))")
    filters.merge! tags: tags
  end

  def search(value)
    @projects = @projects.pg_search(value)
    filters.merge! search: value
  end
end
