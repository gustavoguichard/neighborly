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
end
