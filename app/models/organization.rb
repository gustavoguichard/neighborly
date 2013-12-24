class Organization < ActiveRecord::Base
  belongs_to :user
  attr_accessible :name, :image, :remote_image_url
  mount_uploader :image, OrganizationUploader, mount_on: :image
end
