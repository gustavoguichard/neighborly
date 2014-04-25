require 'spec_helper'

describe NotificationWorker do
  let(:notification) { create(:notification, dismissed: false)}

  before do
    Sidekiq::Testing.inline!
  end

  context 'when notification exists' do
    let(:perform_async) { described_class.perform_async(notification.id)}

    it 'satisfies expectations' do
      expect(NotificationsMailer).to receive(:notify).with(notification).and_call_original
      expect_any_instance_of(Notification).to receive(:update_attributes)
      perform_async
    end
  end

  context 'when user does not exists' do
    let(:perform_async) { described_class.perform_async('aaa')}

    it 'raises a error' do
      expect { perform_async }.to raise_error
    end
  end
end
