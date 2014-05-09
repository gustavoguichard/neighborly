require 'spec_helper'

describe ContributionReport do
  let(:project) { create(:project) }

  it 'takes payment service fees of matched contribution in count' do
    create(:match, project: project, payment_service_fee: 150)
    create(:contribution, project: project)
    subject = described_class.find_by(payment_method: :matched)
    expect(subject.payment_service_fee.to_f).to eql(2.0)
  end
end
