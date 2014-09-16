class ProjectUploader < ImageUploader
  process convert: :jpg

  version :project_thumb do
    process resize_to_fill: [228,178]
  end

  version :project_thumb_small, from_version: :project_thumb do
    process resize_to_fill: [85,67]
  end

  version :project_thumb_large do
    process resize_to_fill: [495,335]
  end

  version :large do
    process resize_to_fill: [750, 422]
  end
end
