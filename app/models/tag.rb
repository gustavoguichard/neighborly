class Tag < ActiveRecord::Base
  has_many :taggings, dependent: :destroy
  validates :name, presence: true, uniqueness: true
  delegate :display_name, to: :decorator
  before_save :lowercase_name

  scope :popular, -> do
    where("exists(select true from taggings where tag_id = tags.id and taggings.project_id in (select project_id from taggings where exists(select true from projects where taggings.project_id = projects.id and projects.state not in('draft', 'rejected')) group by taggings.project_id having count(*) > 2))")
  end

  def decorator
    @decorator ||= TagDecorator.new(self)
  end

  private
  def lowercase_name
     self.name.downcase!
  end
end
