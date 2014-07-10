module ProjectsHelper
  def project_box_classes(project)
    columns_n = if defined? columns then columns else 'large-3 medium-4' end

    classes = if large_project?(project)
      'large large-9 medium-8 columns'
    elsif defined?(contribution) && !browser.mobile?
      'large large-12 medium-12 columns'
    else
      "#{columns_n} columns"
    end
    classes << " #{project.category.to_s.parameterize}" if project.category
    classes << ' soon' if project.soon?

    classes
  end

  def project_content_classes(project)
    if large_project?(project)
      'large-4 medium-4 columns right'
    elsif defined?(contribution) && !browser.mobile?
      'large-3 medium-3 columns'
    end
  end

  def large_project?(project)
    defined?(large) && large
  end
end
