require 'spec_helper'

describe ChannelPolicy do
  subject { described_class }

  shared_examples_for 'update permissions' do
    it 'should deny access to admin if user is nil' do
      should_not permit(nil, Channel.new)
    end

    it 'should deny access to admin if user is not the channel' do
      should_not permit(User.new, Channel.new)
    end

    it 'should permit access to admin if user is the channel' do
      user = User.new
      channel = Channel.new
      channel.user = user
      should permit(user, channel)
    end

    it 'should permit access to admin if user a channel member' do
      user = User.new
      channel = Channel.new
      channel.members << user
      should permit(user, channel)
    end

    it 'should permit access to admin if user is admin' do
      user = User.new
      user.admin = true
      channel = Channel.new
      should permit(user, channel)
    end
  end

  permissions :admin? do
    it_should_behave_like 'update permissions'
  end

  permissions :edit? do
    it_should_behave_like 'update permissions'
  end

  permissions :update? do
    it_should_behave_like 'update permissions'
  end

  permissions :destroy? do
    it_should_behave_like 'update permissions'
  end

  shared_examples_for 'change state permissions' do
    let(:initial_state) { 'draft' }

    it 'should deny access to admin if user is nil' do
      should_not permit(nil, Channel.new(state: initial_state))
    end

    it 'should deny access to admin if user is not the channel' do
      should_not permit(User.new, Channel.new(state: initial_state))
    end

    it 'should deny access to the channel admin' do
      user = User.new
      channel = Channel.new(state: initial_state)
      channel.user = user
      should_not permit(user, channel)
    end

    it 'should deny access to the channel member' do
      user = User.new
      channel = Channel.new(state: initial_state)
      channel.members << user
      should_not permit(user, channel)
    end

    it 'should permit access to admin if user is admin' do
      user = User.new
      user.admin = true
      channel = Channel.new(state: initial_state)
      should permit(user, channel)
    end
  end

  permissions :create? do
    it_should_behave_like 'change state permissions'
  end

  permissions :push_to_draft? do
    it_should_behave_like 'change state permissions'
  end

  permissions :push_to_online? do
    it_should_behave_like 'change state permissions'
  end

  describe 'Scope' do
    shared_examples 'being a non admin user' do
      it 'includes online channels' do
        _channel = create(:channel, state: :online)
        expect(subject.resolve).to include(_channel)
      end

      it 'excludes draft channels from other users' do
        _channel = create(:channel, state: :draft)
        expect(subject.resolve).not_to include(_channel)
      end
    end

    before  { create(:channel) }
    subject { described_class::Scope.new(user, Channel.all) }

    context 'for admin users' do
      let(:user) { User.new(admin: true) }

      it 'is equal to complete collection of resources' do
        expect(subject.resolve).to eql(subject.scope)
      end
    end

    context 'for channel owner' do
      let(:channel) { create(:channel) }
      let(:user)    { channel.user }

      it 'includes the channel' do
        expect(subject.resolve).to eq [channel]
      end

      it_behaves_like 'being a non admin user'
    end

    context 'for channel members' do
      let(:channel) { create(:channel) }
      let(:user)    { create(:user) }

      before do
        channel.members << user
        channel.save
      end

      it 'includes the channel' do
        expect(subject.resolve).to eq [channel]
      end

      it_behaves_like 'being a non admin user'
    end

    context 'for common users' do
      let(:user) { create(:user) }

      it_behaves_like 'being a non admin user'
    end
  end

  describe '#permitted?' do
    shared_examples_for 'permitted attributes' do
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
        { start_content: [] },
        { success_content: [] }
      ]

      (channel_attrs + user_attrs ).each do |field|
        it "permits #{field} field" do
          expect(policy.permitted?(field)).to eq true
        end
      end
    end

    context 'when user is not admin' do
      let(:policy) { described_class.new(nil, Channel.new) }

      it 'does not permit user_id field' do
        expect(policy.permitted?(:user_id)).to eq false
      end

      it_should_behave_like 'permitted attributes'
    end

    context 'when user is an admin' do
      let(:user)   { create(:user, admin: true) }
      let(:policy) { described_class.new(user, Channel.new) }

      it 'permits user_id field' do
        expect(policy.permitted?(:user_id)).to eq true
      end

      it_should_behave_like 'permitted attributes'
    end
  end
end
