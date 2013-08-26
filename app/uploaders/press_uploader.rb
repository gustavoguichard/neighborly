# encoding: utf-8

class PressUploader < ImageUploader

  version :thumb

  version :thumb do
    process resize_to_fill: [170, 60]
    process convert: :png
  end

end

