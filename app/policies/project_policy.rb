class ProjectPolicy < ApplicationPolicy
  def create?
    done_by_owner_or_admin? || is_channel_admin?
  end

  def update?
    create?
  end

  def show?
    if record.draft? || record.soon?
      create?
    else
      true
    end
  end

  def success?
    update?
  end

  def reports?
    update?
  end

  def permitted_attributes
    if user.present? && (!record.instance_of?(Project) || fully_editable?)
      { project: record.attribute_names.map(&:to_sym) + [:address] }
    else
      { project: [:about,         :video_url,            :uploaded_image,
                  :hero_image,    :headline,             :budget,
                  :terms,         :address_neighborhood, :address,
                  :address_city,  :address_state,        :hash_tag,
                  :site, :tag_list] }


    end
  end

  protected

  def fully_editable?
    record.instance_of?(Project) && ( !record.persisted? ||
                                      user.admin? ||
                                      (record.draft? ||
                                       record.rejected? ||
                                       record.soon?) )
  end

  def is_channel_admin?
    user.present? && ( record.last_channel.try(:user) == user ||
                       user.channels.include?(record.last_channel) )
  end
end
