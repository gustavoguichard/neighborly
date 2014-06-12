require 'spec_helper'

describe ContributionReportsForProjectOwner do
  let(:contribution) { create(:contribution) }
  let(:project)      { contribution.project }
  subject { described_class.new(project) }

  it 'iterates through instances of ContributionForProjectOwner\'s' do
    expect(subject.first).to be_a(ContributionForProjectOwner)
  end

  it 'exclude non confirmed contributions from list' do
    contribution = create(:contribution, state: :waiting_confirmation)
    subject      = described_class.new(contribution.project)
    expect(subject).to have(0).items
  end
end
