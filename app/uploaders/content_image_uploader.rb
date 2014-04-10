class ContentImageUploader < ImageUploader
  version :medium do
    process resize_to_limit: [720, 0]
    process :flatten
    process quality: 70
    process convert: :jpg
  end

  # To remove transparency from PNG
  def flatten
    manipulate! do |img|
        img_list = Magick::ImageList.new
        img_list.from_blob img.to_blob
        img_list.new_image(img_list.first.columns, img_list.first.rows) { self.background_color = "white" } # Create new "layer" with white background and size of original image
        img = img_list.reverse.flatten_images
        img
    end
  end
end
