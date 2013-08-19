class PressAsset < ActiveRecord::Base
  validates :title, :url, :image, presence: true
  mount_uploader :image, PressUploader
end
