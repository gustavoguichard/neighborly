class UserPolicy < ApplicationPolicy
  def update?
    done_by_owner_or_admin?
  end

  def credits?
    update?
  end

  def payments?
    is_owned_by?(user)
  end

  def settings?
    update?
  end

  def update_password?
    update?
  end

  def update_email?
    update?
  end

  def set_email?
    update?
  end

  def permitted_attributes
    {
      user: record.attribute_names.map(&:to_sym) -
            user_attributes_black_list +
            additional_user_attributes_white_list
    }
  end

  protected
  def is_owned_by?(user)
    user.present? && record == user
  end

  def additional_user_attributes_white_list
    attrs = [:address, :current_password]
    attrs += organization_attributes
    attrs += channel_attributes if record.channel?
    attrs
  end

  def user_attributes_black_list
    [:confirmed_at,
     :confirmation_token,
     :confirmation_sent_at,
     :unconfirmed_email,
     :admin,
     :created_at,
     :updated_at,
     :encrypted_password,
     :reset_password_token,
     :reset_password_sent_at,
     :remember_created_at,
     :sign_in_count,
     :current_sign_in_at,
     :last_sign_in_at,
     :current_sign_in_ip,
     :last_sign_in_ip,
     :completeness_progress
     ]
  end

  def organization_attributes
    [{organization_attributes: [
        :name,
        :image
        ]
    }]
  end

  def channel_attributes
    [{channel_attributes:
      Channel.attribute_names.map(&:to_sym) - [
        :user_id,
        :state,
        :created_at,
        :updated_at,
        :video_embed_url,
        :accepts_projects,
        :how_it_works_html,
        :submit_your_project_text,
        :submit_your_project_text_html,
        :start_content,
        :start_hero_image,
        :success_content
        ]
    }]
  end
end
