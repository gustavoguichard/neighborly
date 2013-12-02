class ProjectDocument < ActiveRecord::Base
  mount_uploader :document, DocumentUploader, mount_on: :document

  belongs_to :project
end
