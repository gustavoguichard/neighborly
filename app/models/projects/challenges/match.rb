class Projects::Challenges::Match < ActiveRecord::Base
  belongs_to :project
  belongs_to :user

  validates :maximum_value, numericality: { greater_than_or_equal_to: 1_000 }
end
