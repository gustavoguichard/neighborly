require 'spec_helper'

describe Notification do
  let(:contribution){ create(:contribution) }

  before do
    Sidekiq::Testing.fake!
    Notification.unstub(:notify_once)
    ActionMailer::Base.deliveries.clear
  end

  describe 'associations' do
    it { should belong_to :user }
    it { should belong_to :project }
    it { should belong_to :channel }
    it { should belong_to :contribution }
    it { should belong_to :match }
    it { should belong_to :contact }
    it { should belong_to :project_update }
  end

  describe ".notify_once" do
    let(:notification){ create(:notification) }
    let(:notify_once){ Notification.notify_once(notification.template_name, notification.user, filter) }

    shared_examples 'delivering notification' do
      it 'creates a new notification' do
        expect(Notification).to receive(:create!).with(
          locale:        notification.user.locale,
          origin_email:  Configuration[:email_contact],
          origin_name:   Configuration[:company_name],
          template_name: notification.template_name,
          user:          notification.user
        ).and_return(notification)
        notify_once
      end
    end

    context 'when filter is nil' do
      let(:filter) { nil }

      it_behaves_like 'delivering notification'
    end

    context "when filter returns a previous notification" do
      let(:filter) { { user_id: notification.user.id } }

      it 'doesn\'t create a new notification' do
        expect(Notification).to_not receive(:create!)
        notify_once
      end
    end

    context "when filter does not return a previous notification" do
      let(:filter) { { user_id: (notification.user.id + 1) } }

      it_behaves_like 'delivering notification'
    end
  end

end
