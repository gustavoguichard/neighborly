class Organization < ActiveRecord::Base
  belongs_to :user
  mount_uploader :image, OrganizationUploader, mount_on: :image
end
