# encoding: utf-8

class UserUploader < ImageUploader

  version :thumb_avatar do
    process resize_to_fill: [150, 150]
  end

end
