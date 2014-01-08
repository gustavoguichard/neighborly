class OrganizationUploader < ImageUploader

  process quality: 100

  version :thumb do
    process resize_and_pad: [170, 85]
  end

  version :large do
    process resize_and_pad: [300, 150]
  end

end
