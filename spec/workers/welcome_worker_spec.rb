require 'spec_helper'

describe WelcomeWorker do
  let(:user) { create(:user)}

  before do
    Sidekiq::Testing.inline!
  end

  context 'when user exists' do
    let(:perform_async) { described_class.perform_async(user.id)}

    it 'satisfies expectations' do
      expect(Notification).to receive(:notify_once)
      expect_any_instance_of(User).to receive(:update_attribute)
      perform_async
    end
  end

  context 'when user does not exists' do
    let(:perform_async) { described_class.perform_async(42)}

    it 'raises a error' do
      expect { perform_async }.to raise_error
    end
  end
end
