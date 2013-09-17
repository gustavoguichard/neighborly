class Tagging < ActiveRecord::Base
  belongs_to :tag
  belongs_to :project
  validates :tag, :project, presence: true
end
