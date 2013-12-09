class UserDecorator < Draper::Decorator
  decorates :user
  include Draper::LazyHelpers

  def backs_text
    if source.total_backed_projects == 2
      I18n.t('user.backs_text.two')
    elsif source.total_backed_projects > 1
      I18n.t('user.backs_text.many', total: (source.total_backed_projects-1))
    else
      I18n.t('user.backs_text.one')
    end
  end

  def twitter_link
    "http://twitter.com/#{source.twitter}"
  end

  def gravatar_url
    return unless source.email
    "https://gravatar.com/avatar/#{Digest::MD5.new.update(source.email)}.jpg?size=150&default=#{::Configuration[:base_url]}/assets/default-avatar.png"
  end

  def display_name
    if source.company?
      source.company_name || I18n.t('words.no_name')
    else
      source.name || source.full_name || I18n.t('words.no_name')
    end
  end

  def display_image
    if source.company?
      source.company_logo.large.url || '/assets/logo-blank.jpg'
    else
      source.uploaded_image.thumb_avatar.url || source.image_url || source.gravatar_url || '/assets/user.png'
    end
  end

  def display_image_html options={width: 150, height: 150}
    h.content_tag(:figure, h.image_tag(display_image, alt: source.display_name, style: "width: #{options[:width]}px; height: #{options[:height]}px", class: "avatar"), class: "profile-image #{source.profile_type}#{" #{options[:class]}" if options[:class].present?}").html_safe
  end

  def first_name
    display_name.split(' ').first
  end

  def short_name
    truncate display_name, length: 20
  end

  def medium_name
    truncate display_name, length: 42
  end

  def display_credits
    number_to_currency source.credits
  end

  def display_total_of_backs
    number_to_currency source.backs.with_state('confirmed').sum(:value)
  end
end
