class Discover
  attr_accessor :filters
  attr_reader :params

  FILTERS = %w(state near category tags search)
  STATES  = %w(active recommended expiring recent successful soon with_active_matches)

  def initialize(params)
    @filters = {}
    @params  = ActiveSupport::HashWithIndifferentAccess.new(params)
  end

  def projects
    projects = if params[:search].blank?
      Project.group('projects.id')
    else
      Project
    end

    @projects ||= apply_scopes(
      params.compact.slice(*FILTERS), projects.visible
    ).order_for_search.to_a
  end

  private

  def apply_scopes(scopes, projects)
    return projects if scopes.empty?

    scope, value = scopes.shift.flatten
    apply_scopes(scopes, send(scope, value.downcase, projects))
  end

  def state(value, projects)
    return projects unless STATES.include?(value.to_s)

    filters[:state] = value
    projects.send(value)
  end

  def near(value, projects)
    filters[:near] = value
    projects.near(value, 30)
  end

  def category(value, projects)
    category = Category.where('name_en ILIKE ?', value).first
    if category.present?
      filters[:category] = category.to_s
      projects.where(category_id: category.id)
    else
      projects
    end
  end

  def tags(value, projects)
    tags = Project::TagList.new value
    filters[:tags] = tags
    projects.joins(:tags).where(tags: { name: tags })
  end

  def search(value, projects)
    filters[:search] = value
    projects.pg_search(value)
  end
end
