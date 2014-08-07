require 'spec_helper'

describe ContactObserver do
  describe '#after_create' do
    context 'when user to noticate exists' do
      before { create(:user, email: Configuration[:email_contact].dup) }

      it 'notifies the admin' do
        expect(Notification).to receive(:notify_once).at_least(1)
        create(:contact)
      end
    end

    context 'when user does not exists' do
      it 'does not create a notification' do
        expect(Notification).not_to receive(:notify_once)
        create(:contact)
      end

      it 'logs the error' do
        expect(Rails).to receive(:logger).and_call_original
        create(:contact)
      end
    end
  end
end
