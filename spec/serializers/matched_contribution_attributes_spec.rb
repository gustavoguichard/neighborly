require 'spec_helper'

describe MatchedContributionAttributes do
  subject { described_class.new(contribution, match) }
  let(:contribution) do
    Contribution.new(
      project_id: 100,
      state:      :canceled,
      value:      50
    )
  end

  let(:match) do
    Match.new(
      payment_service_fee_paid_by_user: true,
      user_id:                          200,
      value:                            200,
      value_unit:                       3
    )
  end

  describe 'attributes' do
    it 'gets specific attributes from contribution object' do
      expect(subject.attributes[:project_id]).to eql(100)
      expect(subject.attributes[:state]).to      eql(:canceled)
    end

    it 'gets specific attributes from match object' do
      expect(subject.attributes[:payment_service_fee_paid_by_user]).to be_true
      expect(subject.attributes[:user_id]).to                          eql(200)
    end

    it 'sets payment_method as matched' do
      expect(subject.attributes[:payment_method]).to eql(:matched)
    end

    context 'with remaining amount to complete match contribution' do
      before { match.stub(:remaining_amount).and_return(160) }

      it 'defines its value as contribution times match\'s value unit' do
        expect(subject.attributes[:value]).to eql(150)
      end
    end

    context 'with remaining amount to partially match contribution' do
      before { match.stub(:remaining_amount).and_return(90) }

      it 'defines its value limiting to remaining amount' do
        expect(subject.attributes[:value]).to eql(90)
      end
    end
  end
end
