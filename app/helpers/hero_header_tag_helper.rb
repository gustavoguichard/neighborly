module HeroHeaderTagHelper
  def hero_header_tag(object, options = {class: nil}, &block)
    content_tag :header, capture(&block),
      class: [:hero, options[:class], "#{'no-image' unless object.hero_image_url.present?}"],
      style: "#{ "background-image: url(#{image_url(object.hero_image_url(:blur))})" if object.hero_image_url.present?}"
  end
end
