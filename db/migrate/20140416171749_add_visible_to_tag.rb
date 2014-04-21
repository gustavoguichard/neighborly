class AddVisibleToTag < ActiveRecord::Migration
  def change
    add_column :tags, :visible, :boolean, default: false

    popular_tags = Tag.where("exists(select true from taggings where tag_id = tags.id and taggings.tag_id in (select t.tag_id from taggings t where t.project_id in (select p.id from projects p where p.state not in('draft', 'rejected')) group by t.tag_id having count(*) > 3))")
    popular_tags.each do |tag|
      tag.update_column(:visible, true)
    end
  end
end
