module HeroHeaderTagHelper
  def hero_header_tag(object, options = {}, image = nil, &block)
    image ||= object.hero_image_url(:blur) || 'no-image'
    content_tag :header, capture(&block),
      class: [:hero, options[:class], image],
      data: { 'image-url' => image_url(image) }
  end
end
