class Tag < ActiveRecord::Base
  has_many :taggings, dependent: :destroy
  validates :name, presence: true, uniqueness: true
  delegate :display_name, to: :decorator
  before_save :lowercase_name

  scope :popular, -> do
    where("exists(select true from taggings where tag_id = tags.id and taggings.project_id in (select t.project_id from taggings t where t.project_id in (select p.id from projects p where p.id = t.project_id and p.state not in('draft', 'rejected', 'in_analysis') group by p.id having count(*) >= 2)))")
  end

  def decorator
    @decorator ||= TagDecorator.new(self)
  end

  private
  def lowercase_name
     self.name.downcase!
  end
end
