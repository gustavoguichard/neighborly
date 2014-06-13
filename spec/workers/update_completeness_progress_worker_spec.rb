require 'spec_helper'

describe UpdateCompletenessProgressWorker do
  let!(:user) { create(:user)}
  before      { Sidekiq::Testing.inline! }

  context 'when user exists' do
    let(:perform_async) { described_class.perform_async(user.id)}

    it 'satisfies expectations' do
      expect_any_instance_of(User).to receive(:update_completeness_progress!)
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
