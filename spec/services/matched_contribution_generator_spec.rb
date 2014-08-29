require 'spec_helper'

describe MatchedContributionGenerator do
  subject { described_class.new(contribution) }
  let!(:contribution) { create(:contribution) }

  describe '#create' do
    it 'generates a new contribution for each active match for the related project' do
      create_list(:match, 2, project: contribution.project)
      expect {
        subject.create
      }.to change(Contribution, :count).by(2)
    end

    it 'uses MatchedContributionAttributes to get attributes for new contributions' do
      attrs = { foo: 'bar' }
      MatchedContributionAttributes.any_instance.
        stub(:attributes).
        and_return(attrs)
      create(:match, project: contribution.project)

      expect(Contribution).to receive(:create!).with(attrs).and_return(build(:contribution))
      subject.create
    end

    it 'ensures no matching of inactive matches' do
      create(:match,
        project:     contribution.project,
        starts_at:   2.days.from_now,
        finishes_at: contribution.project.expires_at
      )
      expect {
        subject.create
      }.to_not change(Contribution, :count)
    end

    it 'ensures no matching with matches related to other projects' do
      project = create(:project)
      create(:match,
        project:     project,
        starts_at:   1.day.from_now,
        finishes_at: project.expires_at
      )

      expect {
        subject.create
      }.to_not change(Contribution, :count)
    end

    it 'notify observers when remaining amount of a mach is zero' do
      match = create(:match, project: contribution.project)
      MatchFinisher.stub(:remaining_amount_of).and_return(0)
      expect(Match).to receive(:notify_observers).with(:match_been_met, match)
      subject.create
    end
  end

  describe '#update' do
    before do
      create(:match, project: contribution.project)
      subject.create
    end

    it 'updates state of each matched contribution' do
      contribution.push_to_trash
      expect(
        contribution.matched_contributions.pluck(:state).uniq
      ).to eql([contribution.state])
    end

    it 'ensures that not update non related contributions' do
      unrelated_contribution = create(:contribution)
      contribution.push_to_trash
      expect(unrelated_contribution.state).to_not eql(contribution.state)
    end

    it 'ensures that not update non related matched contributions' do
      unrelated_contribution = create(:contribution)
      described_class.new(unrelated_contribution).create

      contribution.push_to_trash
      expect(
        unrelated_contribution.matched_contributions.pluck(:state).uniq
      ).to_not eql([contribution.state])
    end
  end
end
