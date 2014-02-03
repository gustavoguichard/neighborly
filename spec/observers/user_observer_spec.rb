require 'spec_helper'

describe UserObserver do

  describe '#before_validation' do
    let(:user) { build(:user, password: nil) }
    before { user.valid? }
    it { expect(user.password).to_not be_empty }
  end

  describe '#after_create' do
    before { UserObserver.any_instance.unstub(:after_create) }
    context 'when the user is with temporary email' do
      let(:user) { create(:user, email: "change-your-email+#{Time.now.to_i}@neighbor.ly") }
      before { expect_any_instance_of(WelcomeWorker).to_not receive(:perform_async) }
      it { user }
    end

    context 'when the user is not with temporary email' do
      before { expect(WelcomeWorker).to receive(:perform_async) }
      it { create(:user) }
    end
  end

  describe "#after_save" do
    context 'when profile is complete' do
      before do
        @user = create(:user, completeness_progress: 100)
        expect_any_instance_of(User).to_not receive(:update_completeness_progress!)
        @user.name = 'test'
      end

      it { @user.save }
    end

    context 'when profile is not complete' do
      before do
        @user = create(:user, completeness_progress: 50)
        expect_any_instance_of(User).to receive(:update_completeness_progress!)
        @user.name = 'test'
      end

      it { @user.save }
    end
  end

end
