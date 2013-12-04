# encoding: utf-8

class UserUploader < ImageUploader

  version :thumb_avatar

  version :thumb_avatar do
    process resize_to_fill: [150, 150]
    process convert: :jpg
    process quality: 60
  end

end
