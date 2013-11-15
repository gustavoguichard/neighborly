# encoding: utf-8

class HeroImageUploader < ImageUploader

  version :hero_image

  def store_dir
    "uploads/project/#{mounted_as}/#{model.id}"
  end

  version :hero_image do
    process :apply_blur
    process convert: :png
  end

  def apply_blur
    manipulate! do |img|
      img = img.blur_image(0, 2.5)
      img
    end
  end

end
