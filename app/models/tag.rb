class Tag < ActiveRecord::Base
  has_many :taggings, dependent: :destroy
  validates :name, presence: true, uniqueness: true
  delegate :display_name, to: :decorator
  before_save :lowercase_name

  def decorator
    @decorator ||= TagDecorator.new(self)
  end

  private
  def lowercase_name
     self.name.downcase!
  end
end
