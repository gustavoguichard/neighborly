require 'spec_helper'

describe ChannelsSubscriberPolicy do
  subject { described_class }

  let(:subscription) { create(:channels_subscriber) }
  let(:user) { subscription.user }

  shared_examples_for 'show permissions' do
    it 'denies access if user is nil' do
      expect(subject).not_to permit(nil, subscription)
    end

    it 'denies access if user is not updating his subscription' do
      expect(subject).not_to permit(User.new, subscription)
    end

    it 'authorizes access if user is subscription owner' do
      expect(subject).to permit(user, subscription)
    end

    it 'authorizes access if user is admin' do
      admin = build(:user, admin: true)
      expect(subject).to permit(admin, subscription)
    end
  end

  permissions(:show?) { it_should_behave_like 'show permissions' }

  permissions(:destroy?) { it_should_behave_like 'show permissions' }
end
