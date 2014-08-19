class ChannelPolicy < ApplicationPolicy
  def create?
    is_admin?
  end

  def update?
    user.present? && (record.user == user ||
                      record.members.include?(user) ||
                      is_admin?
                     )
  end

  def admin?
    update?
  end

  def destroy?
    update?
  end

  def push_to_draft?
    is_admin? && record.can_push_to_draft?
  end

  def push_to_online?
    is_admin? && record.can_push_to_online?
  end

  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.admin?
        scope
      else
        owned = scope.where(user: user)
        membered = scope.where(id: user.channels.map(&:id))
        online = scope.with_state('online')
        scope.from("(#{owned.to_sql} UNION #{membered.to_sql} UNION #{online.to_sql}) as channels")
      end
    end
  end

  def permitted_attributes(params = {})
    user_attrs = [
      user_attributes: [:email,
                        :password,
                        :facebook_url,
                        :twitter_url,
                        :other_url]
    ]

    channel_attrs = [
      :name,
      :description,
      :permalink,
      :image,
      :video_url,
      :how_it_works,
      :terms_url,
      :accepts_projects,
      :submit_your_project_text,
      :start_hero_image,
      { start_content: params.try(:[], :channel).
                            try(:[], :start_content).
                            try(:keys).to_a },
      { success_content: params.try(:[], :channel).
                              try(:[], :success_content).
                              try(:keys).to_a }
    ]

    if is_admin?
      channel_attrs = channel_attrs + [:user_id]
    end

    { channel: channel_attrs + user_attrs }
  end
end
