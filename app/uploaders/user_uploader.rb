# encoding: utf-8

class UserUploader < ImageUploader

  version :thumb_avatar do
    process quality: 100
    process resize_to_fill: [150, 150]
  end

end
