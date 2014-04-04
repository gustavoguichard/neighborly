class Image < ActiveRecord::Base
  belongs_to :user
  validates :file, presence: true

  mount_uploader :file, UserUploader, mount_on: :file
end
