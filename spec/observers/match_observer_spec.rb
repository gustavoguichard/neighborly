require 'spec_helper'

describe MatchObserver do
  let!(:match)       { create(:match, state: :confirmed) }
  let(:contribution) { create(:contribution, state: :confirmed) }

  before do
    Notification.unstub(:notify)
    Notification.unstub(:notify_once)
    create_list(:matching, 2, match: match)
    create(:matching)
  end

  describe '#cancel_matched_contributions' do
    before { match.cancel! }

    it 'cancels matched contributions' do
      match.matched_contributions.each do |contribution|
        expect(contribution.confirmed?).to be_false
      end
    end
  end

  describe '#completed' do
    it 'notifies match owner about match ended' do
      expect(Notification).to receive(:notify_once).
          with(:match_ended,
               match.user,
               { match_id: match.id },
               { match: match })

      match.notify_observers :completed
    end
  end
end
