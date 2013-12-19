require 'spec_helper'

describe UserObserver do

  describe "after_create" do
    before do
      UserObserver.any_instance.should_receive(:after_create).and_call_original
      Notification.unstub(:notify_once)
    end

    let(:user) { create(:user, newsletter: false) }

    it "send new user registration notification" do
      Notification.should_receive(:notify_once).with(:new_user_registration, user, {user_id: user.id}, {user: user})
    end

    it 'should set the newsletter to true' do
      expect(user.newsletter).to be_true
    end
  end

end
