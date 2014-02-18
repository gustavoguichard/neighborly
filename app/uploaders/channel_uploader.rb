class ChannelUploader < ImageUploader

  process quality: 100

  version :thumb do
    process resize_and_pad: [170, 85]
  end

  version :large do
    process resize_and_pad: [300, 150]
  end

  version :x_large do
    process resize_and_pad: [600, 300]
  end
end
