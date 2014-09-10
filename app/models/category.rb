class Category < ActiveRecord::Base
  has_many :projects
  validates_presence_of :name_pt
  validates_uniqueness_of :name_pt

  def name
    to_s
  end

  def self.with_projects
    where("exists(select true from projects p where p.category_id = categories.id and p.state not in('draft', 'rejected'))")
  end

  def self.array
    [['Select an option', '']].concat order('name_'+ I18n.locale.to_s + ' ASC').collect { |c| [c.send('name_' + I18n.locale.to_s), c.id] }
  end

  def to_s
    self.send('name_' + I18n.locale.to_s)
  end
end
