# encoding: utf-8

class UserUploader < ImageUploader

  version :thumb_avatar
  version :background_image

  version :thumb_avatar do
    process resize_to_fill: [119,121]
    process convert: :png
  end

  version :background_image do
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
