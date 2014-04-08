require 'spec_helper'

describe UserPolicy do
  subject { described_class }

  shared_examples_for 'update permissions' do
    it 'denies access if user is nil' do
      expect(subject).not_to permit(nil, User.new)
    end

    it 'denies access if user is not the owner' do
      expect(subject).not_to permit(User.new, User.new)
    end

    it 'authorizes access if user is the owner' do
      new_user = User.new
      expect(subject).to permit(new_user, new_user)
    end

    it 'authorizes access if user is admin' do
      admin = User.new
      admin.admin = true
      expect(subject).to permit(admin, User.new)
    end
  end

  permissions :edit? do
    it_should_behave_like 'update permissions'
  end

  permissions :update? do
    it_should_behave_like 'update permissions'
  end

  permissions :credits? do
    it_should_behave_like 'update permissions'
  end

  permissions :settings? do
    it_should_behave_like 'update permissions'
  end

  permissions :update_password? do
    it_should_behave_like 'update permissions'
  end

  permissions :update_email? do
    it_should_behave_like 'update permissions'
  end

  permissions :set_email? do
    it_should_behave_like 'update permissions'
  end

  permissions :payments? do
    it 'denies access if user is nil' do
      expect(subject).not_to permit(nil, User.new)
    end

    it 'denies access if user is not the owner' do
      expect(subject).not_to permit(User.new, User.new)
    end

    it 'authorizes access if user is the owner' do
      new_user = User.new
      expect(subject).to permit(new_user, new_user)
    end

    it 'denies access if user is admin' do
      admin = User.new
      admin.admin = true
      expect(subject).not_to permit(admin, User.new)
    end
  end

  describe '#permitted?' do
    let(:user) { User.new }
    let(:policy){ described_class.new(nil, user) }

    user_attributes_black_list = [
      :confirmed_at,
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

    user_attributes_black_list.each do |field|
      it "does not permit when field is #{field}" do
        expect(policy.permitted?(field.to_sym)).not_to be_true
      end
    end

    (User.attribute_names.map(&:to_sym) -
     user_attributes_black_list +
     [:address, :current_password]
    ).each do |field|
      it "permit when field is #{field}" do
        expect(policy.permitted?(field.to_sym)).to be_true
      end
    end

    it 'permit organization fields' do
      attrs = { organization_attributes: [ :name, :image ] }
      expect(policy.permitted?(attrs)).to be_true
    end

    context 'when user type is a channel' do
      let(:user) { User.new profile_type: 'channel' }

      it 'permit channel fields' do
        attrs = {channel_attributes:
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
                }
        expect(policy.permitted?(attrs)).to be_true
      end
    end

    context 'when user type is not a channel' do
      let(:user) { User.new profile_type: 'organization' }

      it 'does not permit channel fields' do
        attrs = {channel_attributes:
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
                }
        expect(policy.permitted?(attrs)).not_to be_true
      end
    end
  end
end
