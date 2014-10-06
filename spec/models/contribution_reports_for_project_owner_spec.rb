require 'spec_helper'

describe ContributionReportsForProjectOwner do
  let(:project) { create(:project) }

  it 'exclude non confirmed contributions from list' do
    create(:contribution, state: 'pending', project: project)
    expect(described_class.per_project(project)).to have(0).items
  end
end
