class ProjectPolicy < ApplicationPolicy
  def create?
    done_by_owner_or_admin? || is_channel_admin?
  end

  def update?
    create?
  end

  def destroy?
    create? && record.can_push_to_trash?
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

  def approve?
    change_state? && record.can_approve?
  end

  def launch?
    change_state? && record.can_launch?
  end

  def reject?
    change_state? && record.can_reject?
  end

  def push_to_draft?
    change_state? && record.can_push_to_draft?
  end

  def permitted_attributes
    if user.present? && (!record.instance_of?(Project) || fully_editable?)
      { project: record.attribute_names.map(&:to_sym) + [:location, :tag_list] }
    else
      { project: [:about,         :video_url,            :uploaded_image,
                  :hero_image,    :headline,             :budget,
                  :terms,         :address_neighborhood, :location,
                  :address_city,  :address_state,        :hash_tag,
                  :site, :tag_list] }


    end
  end

  protected

  def change_state?
    user.present? && (user.admin? || is_channel_admin?)
  end

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
