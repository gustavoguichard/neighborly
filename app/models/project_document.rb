class ProjectDocument < ActiveRecord::Base
  mount_uploader :document, DocumentUploader, mount_on: :document

  validates :name, presence: true
  belongs_to :project
end
