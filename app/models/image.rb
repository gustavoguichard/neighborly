class Image < ActiveRecord::Base
  belongs_to :user
  validates :file, presence: true

  mount_uploader :file, ContentImageUploader, mount_on: :file
end
