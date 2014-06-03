require 'spec_helper'

describe SubscriberReport do
  let!(:channel)   { create(:channel) }
  let!(:user)      { create(:user, subscriptions: [ channel ]) }
  let(:subscriber) { described_class.first }

  describe 'associations' do
    it { should belong_to :channel }
  end

  it 'retuns one record' do
    expect(described_class.count).to eq 1
  end

  it 'channel_id returns the correct channel id' do
    expect(subscriber.channel_id).to eq(channel.id)
  end

  it 'name returns user name' do
    expect(subscriber.name).to eq(user.name)
  end

  it 'email returns user email' do
    expect(subscriber.email).to eq(user.email)
  end
end
