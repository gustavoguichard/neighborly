class Tag < ActiveRecord::Base
  has_many :taggings, dependent: :destroy
  validates :name, presence: true
end
