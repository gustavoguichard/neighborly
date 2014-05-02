require 'spec_helper'

describe MatchedContributionGenerator do
  subject { described_class.new(contribution) }
  let(:contribution) { create(:contribution) }

  describe '#create' do
    it 'generates a new contribution for each active match for the related project' do
      create_list(:match, 2, project: contribution.project)
      expect {
        described_class.new(contribution).create
      }.to change(Contribution, :count).by(2)
    end

    it 'uses MatchedContributionAttributes to get attributes for new contributions' do
      attrs = { foo: 'bar' }
      MatchedContributionAttributes.any_instance.
        stub(:attributes).
        and_return(attrs)
      create(:match, project: contribution.project)

      expect(Contribution).to receive(:create).with(attrs).and_return(build(:contribution))
      described_class.new(contribution).create
    end

    it 'ensures no matching of inactive matches' do
      create(:match,
        project:     contribution.project,
        starts_at:   1.day.from_now,
        finishes_at: contribution.project.expires_at
      )
      expect {
        described_class.new(contribution).create
      }.to_not change(Contribution, :count)
    end

    it 'ensures no matching with matches related to other projects' do
      project = create(:project)
      create(:match,
        project:     project,
        starts_at:   1.day.from_now,
        finishes_at: project.expires_at
      )
      described_class.new(contribution).create
    end
  end
end
