require 'spec_helper'

describe MatchObserver do
  let!(:match)       { create(:match, state: :confirmed) }
  let(:contribution) { create(:contribution, state: :confirmed) }

  before do
    matching = create(:matching, match: match, contribution: contribution)
    create(:contribution, matching_id: matching.id)
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

  describe '#match_been_met' do
    it 'notifies match owner about match been met and contributors' do
      expect(Notification).to receive(:notify_once).
          with(:match_been_met,
               match.user,
               { match_id: match.id },
               { match: match }).ordered

      expect(Notification).to receive(:notify_once).
          with(:contribution_match_was_met,
               contribution.user,
               { contribution_id: contribution.id },
               { contribution: contribution }).ordered

      match.notify_observers :match_been_met
    end
  end

  describe '#became_active' do
    it 'generates a new update' do
      expect {
        match.notify_observers :became_active
      }.to change(Update, :count).by(1)
    end
  end
end
