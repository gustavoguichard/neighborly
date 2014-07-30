require 'spec_helper'

describe ChannelPolicy do
  subject { described_class }

  permissions :admin? do
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

    it 'should permit access to admin if user is adminl' do
      user = User.new
      user.admin = true
      channel = Channel.new
      should permit(user, channel)
    end
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
end
