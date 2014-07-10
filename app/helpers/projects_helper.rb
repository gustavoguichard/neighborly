module ProjectsHelper
  def project_box_classes(project, is_large, contribution, columns)
    classes = if is_large
      'large large-9 medium-8 columns'
    elsif contribution && !browser.mobile?
      'large large-12 medium-12 columns'
    else
      columns_n = columns || 'large-3 medium-4'
      "#{columns_n} columns"
    end
    classes << " #{project.category.to_s.parameterize}" if project.category
    classes << ' soon' if project.soon?

    classes
  end

  def project_content_classes(project, is_large, contribution)
    if is_large
      'large-4 medium-4 columns right'
    elsif contribution && !browser.mobile?
      'large-3 medium-3 columns'
    end
  end
end
