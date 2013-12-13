# encoding: utf-8

class PressUploader < ImageUploader

  process convert: :png
  process quality: 100

  version :thumb do
    process resize_to_fill: [170, 60]
  end

end

