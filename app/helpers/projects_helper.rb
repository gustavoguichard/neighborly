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

  def remaining_days(project)
    [
      content_tag(:strong, project.remaining_days),
      project.time_to_go[:unit].capitalize,
      pluralize_without_number(project.time_to_go[:time],
                               t('words.remaining_singular'),
                               t('words.remaining_plural')
      )
    ].join(" ").html_safe
  end

  def display_status(project)
    content_tag :span do
      t("projects.show.display_status.#{project.campaign_type}.#{project.display_status}",
        goal: project.display_goal,
        date: (l(project.expires_at.to_date, format: :long) rescue nil))
    end
  end
end
