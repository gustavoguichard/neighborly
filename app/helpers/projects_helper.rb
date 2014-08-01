module ProjectsHelper
  def project_box_classes(project, is_large, contribution, columns)
    classes = if contribution && !browser.mobile?
      'large large-12 medium-12'
    elsif is_large
      'large large-9 medium-8'
    else
      columns || 'large-3 medium-4'
    end
    classes << " #{project.category.to_s.parameterize}" if project.category
    classes << ' soon' if project.soon?

    classes << ' columns left'
  end

  def project_content_classes(project, is_large, contribution)
    if contribution && !browser.mobile?
      'large-3 medium-3 columns right'
    elsif is_large
      'large-4 medium-4 columns right'
    end
  end
end
