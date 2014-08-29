require 'spec_helper'

describe UserObserver do
  before do
    allow_any_instance_of(User).to receive(:transaction_record_state).
      with(:new_record).and_return(true)
  end

  describe '#before_validation' do
    let(:user) { build(:user, password: nil) }

    it 'creates a password' do
      user.valid?
      expect(user.password).to_not be_empty
    end
  end

  describe '#after_commit' do
    context 'when the user is with temporary email' do
      it 'does not send to worker' do
        subject = create(:user, email: "change-your-email+#{Time.now.to_i}@neighbor.ly")
        expect(WelcomeWorker).to_not receive(:perform_async)
        subject.run_callbacks(:commit)
      end
    end

    context 'when the user is not with temporary email' do
      it 'sends to worker' do
        subject = create(:user)
        expect(WelcomeWorker).to receive(:perform_async)
        subject.run_callbacks(:commit)
      end
    end
  end

  describe '#after_save' do
    context 'when profile is complete' do
      it 'does not send to worker' do
        @user = create(:user, completeness_progress: 100)
        expect(UpdateCompletenessProgressWorker).to_not receive(:perform_async)
        @user.name = 'test'
        @user.save
      end
    end

    context 'when profile is not complete' do
      it 'sends to worker' do
        @user = create(:user, completeness_progress: 50)
        expect(UpdateCompletenessProgressWorker).to receive(:perform_async).with(@user.id)
        @user.name = 'test'
        @user.save
      end
    end
  end
end
