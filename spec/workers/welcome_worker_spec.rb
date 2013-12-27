require 'spec_helper'

describe WelcomeWorker do
  let(:user) { create(:user)}
  let(:perform_async) { WelcomeWorker.perform_async(user.id)}

  before do
    Sidekiq::Testing.inline!

    Notification.should_receive(:notify_once)
    User.any_instance.should_receive(:update_attribute)
  end

  it "should satisfy expectations" do
    perform_async
  end
end
