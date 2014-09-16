class Activity < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
  validates :title, :happened_at, :project, :user, presence: true
  validates :summary, length: { maximum: 140 }, allow_nil: true
end
