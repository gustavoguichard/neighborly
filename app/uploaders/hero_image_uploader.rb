# encoding: utf-8

class HeroImageUploader < ImageUploader

  version :blur do
    process resize_to_limit: [2000, 0]
    process :apply_blur
    process quality: 70
  end

  def apply_blur
    manipulate! do |img|
      img.blur_image(0, 5)
    end
  end

end
