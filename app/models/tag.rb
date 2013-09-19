class Tag < ActiveRecord::Base
  has_many :taggings, dependent: :destroy
  validates :name, presence: true, uniqueness: true
  delegate :display_name, to: :decorator

  def decorator
    @decorator ||= TagDecorator.new(self)
  end
end
