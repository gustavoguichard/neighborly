# encoding: utf-8

class ProjectUploader < ImageUploader

  version :project_thumb
  version :project_thumb_small
  version :project_thumb_facebook

  def store_dir
    "uploads/project/#{mounted_as}/#{model.id}"
  end

  version :project_thumb do
    process resize_to_fill: [228,178]
    process convert: :jpg
    process quality: 60
  end

  version :project_thumb_small, from_version: :project_thumb do
    process resize_to_fill: [85,67]
    process quality: 60
    process convert: :jpg
  end

  version :project_thumb_large do
    process resize_to_fill: [495,335]
    process quality: 65
    process convert: :jpg
  end

  #facebook requires a minimum thumb size
  version :project_thumb_facebook do
    process resize_to_fill: [512,400]
    process quality: 60
    process convert: :jpg
  end

end
