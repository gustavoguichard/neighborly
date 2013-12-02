# encoding: utf-8

class HeroImageUploader < ImageUploader

  version :blur

  def store_dir
    "uploads/project/#{mounted_as}/#{model.id}"
  end

  version :blur do
    process resize_to_limit: [2000, 0]
    process :apply_blur
    process convert: :png
  end

  def apply_blur
    manipulate! do |img|
      img.blur_image(0, 4)
    end
  end

end
