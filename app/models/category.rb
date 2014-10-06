class Category < ActiveRecord::Base
  has_many :projects
  validates_presence_of :name
  validates_uniqueness_of :name

  def self.with_projects
    where("exists(select true from projects p where p.category_id = categories.id and p.state not in('draft', 'rejected'))")
  end

  def self.array
    [['Select an option', '']].concat order('name ASC').collect { |c| [c.send('name'), c.id] }
  end

  def to_s
    name
  end
end
