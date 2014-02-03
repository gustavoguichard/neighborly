class ProjectDecorator < Draper::Decorator
  decorates :project
  include Draper::LazyHelpers

  def remaining_text
    pluralize_without_number(time_to_go[:time], I18n.t('words.remaining_singular'), I18n.t('words.remaining_plural'))
  end

  def time_to_go
    time_and_unit = nil
    %w(day hour minute second).detect do |unit|
      time_and_unit = time_to_go_for unit
    end
    time_and_unit || time_and_unit_attributes(0, 'second')
  end

  def remaining_days
    source.time_to_go[:time]
  end

  def display_status
    if source.online?
      (source.reached_goal? ? 'reached_goal' : 'not_reached_goal')
    else
      source.state
    end
  end

  # Method for width of progress bars only
  def display_progress
    return 100 if (source.successful? and source.reached_goal?) || source.progress > 100
    return 8 if source.progress > 0 and source.progress < 8
    source.progress
  end

  def display_image(version = 'project_thumb' )
    use_uploaded_image(version) || use_video_tumbnail(version)
  end

  def display_address_formated
    text = ""
    if source.address_city || source.address_state
      text += "#{source.address_neighborhood} // " unless source.address_neighborhood.blank?
      text += source.address_city unless source.address_city.blank?
      text += "#{source.address_city.present? ? ', ' : ''}#{source.address_state}" unless source.address_state.blank?
    end
    text
  end

  def display_video_embed_url
    if source.video_embed_url
      "//#{source.video_embed_url}?title=0&byline=0&portrait=0&autoplay=0&color=ffffff&badge=0&modestbranding=1&showinfo=0&border=0&controls=2".gsub('http://', '')
    end
  end

  def display_expires_at
    source.expires_at ? I18n.l(source.expires_at.to_date) : ''
  end

  def display_pledged
    number_to_currency source.pledged, precision: 0
  end

  def display_goal
    number_to_currency source.goal, precision: 0
  end

  def progress_bar
    width = source.display_progress
    width = 5 if width < 1 && source.contributions.with_state('confirmed').size > 0
    content_tag(:div, class: [:progress, :round]) do
      content_tag(:span, nil, class: :meter, style: "width: #{width}%")
    end
  end


  def successful_flag
    return nil unless source.successful?

    content_tag(:div, class: [:successful_flag]) do
      image_tag("successful.#{I18n.locale}.png")
    end

  end

  private

  def use_uploaded_image(version)
    source.uploaded_image.send(version).url if source.uploaded_image.present?
  end

  def use_video_tumbnail(version)
    if source.video_thumbnail.url.present?
      source.video_thumbnail.send(version).url
    elsif source.video
      source.video.thumbnail_large rescue nil
    end
  end

  def time_to_go_for(unit)
    time = 1.send(unit)

    if source.expires_at.to_i >= time.from_now.to_i
      time = ((source.expires_at - Time.zone.now).abs / time).round
      time_and_unit_attributes time, unit
    end
  end

  def time_and_unit_attributes(time, unit)
    { time: time, unit: pluralize_without_number(time, I18n.t("datetime.prompts.#{unit}").downcase) }
  end
end

