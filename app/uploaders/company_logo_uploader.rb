class CompanyLogoUploader < ImageUploader

  version :thumb do
    process resize_to_fill: [160, 75]
  end

  version :large do
    process resize_to_fill: [320, 150]
  end

end
