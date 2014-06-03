require 'spec_helper'

describe MatchActivationWorker do
  describe 'performation' do
    it 'notifies observers of each new activated match' do
      match = Match.new
      Match.stub(:activating_today).and_return([match])
      expect(match).to receive(:notify_observers).with(:became_active)
      subject.perform
    end
  end
end

