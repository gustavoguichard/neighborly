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

  def display_organization_type
    I18n.t("project.organization_type.#{source.organization_type}")
  end

  def display_yield
    rewards = source.rewards.by_yield
    if rewards.first.try(:yield).present?
      [
        number_to_percentage(rewards.first.yield, precision: 2, strip_insignificant_zeros: true),
        number_to_percentage(rewards.last.yield, precision: 2, strip_insignificant_zeros: true),
      ].uniq.join(' - ')
    else
      content_tag :abbr, 'TBD', title: 'To be determined'
    end
  end

  def rating_description
    rating_index = Project.ratings[source.rating]
    if rating_index
      t('projects.hero.rating_definitions')[rating_index]
    else
      ''
    end
  end

  def maturity_period
    if source.rewards.any?
      [
        source.rewards.first.happens_at.year,
        source.rewards.last.happens_at.year
      ].uniq.join('-')
    else
      ''
    end
  end

  private

  def use_uploaded_image(version)
    source.uploaded_image.send(version).url
  end

  def use_video_tumbnail(version)
    source.video_thumbnail.send(version).url ||
      'image-placeholder-upload-in-progress.jpg'
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

