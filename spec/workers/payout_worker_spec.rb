require 'spec_helper'

describe PayoutWorker do
  describe 'performation' do
    it 'generates new Payout for the project' do
      expect(Payout).to receive(:complete).with(2, 3)
      subject.perform(2, 3)
    end
  end
end
