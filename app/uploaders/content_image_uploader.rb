class ContentImageUploader < ImageUploader
  version :medium do
    process resize_to_limit: [720, 0]
    process quality: 70
  end
end
