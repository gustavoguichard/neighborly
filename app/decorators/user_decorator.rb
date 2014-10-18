class UserDecorator < Draper::Decorator
  decorates :user
  include Draper::LazyHelpers

  def display_name
    if source.organization? && source.organization.present?
      source.organization.name || source.email
    else
      source.name || source.email
    end
  end

  def display_image
    if source.organization? && source.organization.present?
      source.organization.image.large.url || '/assets/logo-blank.jpg'
    else
      source.uploaded_image.thumb_avatar.url || source.image_url || image_url("default-avatars/#{[*1..11].sample}.png")
    end
  end

  def display_image_html(options = { width: 150, height: 150 })
    h.content_tag(:figure, h.image_tag(display_image, alt: source.display_name, style: "width: #{options[:width]}px; height: #{options[:height]}px", class: "avatar"), class: "profile-image #{source.profile_type}#{" #{options[:class]}" if options[:class].present?}").html_safe
  end

  def first_name
    display_name.split(' ').first
  end

  def last_name
    display_name.split(' ').last
  end

  def short_name
    truncate display_name, length: 20
  end

  def medium_name
    truncate display_name, length: 42
  end

  def display_total_of_contributions
    number_to_currency source.contributions.with_state('confirmed').sum(:value)
  end

  def referral_url
    main_app.new_user_registration_url(referral_code: source.referral_code)
  end
end
