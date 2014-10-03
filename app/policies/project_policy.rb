class ProjectPolicy < ApplicationPolicy
  def create?
    done_by_owner_or_admin?
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

  def destroy?
    change_state? && record.can_push_to_trash?
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
      {
        project: record.attribute_names.map(&:to_sym) +
                 [:location, :tag_list] -
                 [
                   :sale_date, :created_at, :updated_at, :summary_html,
                   :budget_html, :terms_html, :sent_to_analysis_at
                 ]
      }
    else
      { project: [:summary,       :video_url,            :uploaded_image,
                  :hero_image,    :headline,             :budget,
                  :terms,         :address_neighborhood, :location,
                  :address_city,  :address_state,        :hash_tag,
                  :site,          :tag_list,             :statement_file_url,
                  :credit_type,   :minimum_investment] }


    end
  end

  protected

  def change_state?
    user.present? && (user.admin?)
  end

  def fully_editable?
    record.instance_of?(Project) && ( !record.persisted? ||
                                      user.admin? ||
                                      (record.draft? ||
                                       record.rejected? ||
                                       record.soon?) )
  end

  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.admin?
        scope
      else
        scope.where(user_id: user.id)
      end
    end
  end
end
