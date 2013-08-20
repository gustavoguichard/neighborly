# encoding: utf-8

class DocumentUploader < CarrierWave::Uploader::Base

  def store_dir
    "uploads/project_documents/#{mounted_as}/#{model.id}"
  end

  def filename
    File.basename(self.file.file)
  end
end
