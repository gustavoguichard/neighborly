# encoding: utf-8

class ProfileUploader < ImageUploader

  version :curator_thumb do
    process resize_to_fill: [218, 123]
    process convert: :png
  end

end
