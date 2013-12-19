class CompanyLogoUploader < ImageUploader

  version :thumb do
    process resize_to_fill: [170, 85]
  end

  version :large do
    process resize_to_fill: [300, 150]
  end

end
