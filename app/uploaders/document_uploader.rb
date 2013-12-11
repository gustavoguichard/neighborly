# encoding: utf-8

class DocumentUploader < CarrierWave::Uploader::Base

  def store_dir
    "uploads/project_documents/#{mounted_as}/#{model.id}"
  end

  def self.choose_storage
    (Rails.env.production? and Configuration[:aws_access_key]) ? :fog : :file
  end

  storage choose_storage

  def filename
    File.basename(self.url) if self.url.present?
  end
end
