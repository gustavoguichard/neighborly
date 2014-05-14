require 'spec_helper'

describe MatchObserver do
  let!(:match)       { create(:match, state: :confirmed) }
  let(:contribution) { create(:contribution, state: :confirmed) }

  before do
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
end
