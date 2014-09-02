require 'spec_helper'

describe NotificationObserver do
  before do
    allow_any_instance_of(Notification).to receive(:transaction_record_state).
      with(:new_record).and_return(true)
  end

  describe '#after_commit' do
    it 'delivers it asynchronously when not dismissed' do
      subject = create(:notification, dismissed: false)
      expect(NotificationWorker).to receive(:perform_async)
      subject.run_callbacks(:commit)
    end

    it 'doesn\'t deliver it when dismissed' do
      subject = create(:notification, dismissed: true)
      expect(NotificationWorker).to_not receive(:perform_async)
      subject.run_callbacks(:commit)
    end
  end
end
