require 'spec_helper'

describe ProjectFinancialsByService do
  subject { described_class.find_by(project_id: project) }
  let(:project) { create(:project, state: 'online') }
  before { Configuration[:platform_fee] = 0.1 }

  describe 'net amount' do
    it 'does not take non confirmed contributions in count' do
      create(
        :contribution,
        value:                            100,
        payment_method:                   'balanced',
        payment_service_fee:              1,
        payment_service_fee_paid_by_user: false,
        project:                          project,
        state:                            'confirmed'
      )
      create(
        :contribution,
        value:                            100,
        payment_method:                   'balanced',
        payment_service_fee:              1,
        payment_service_fee_paid_by_user: false,
        project:                          project,
        state:                            'waiting_confirmation'
      )
      expect(subject.net_amount.to_f).to eql(89.0)
    end

    context 'with payment service fees paid by project owner' do
      it 'sums contributions values taking platform_fee and payment_service_fee out' do
        create(
          :contribution,
          value:                            100,
          payment_method:                   'balanced',
          payment_service_fee:              1,
          payment_service_fee_paid_by_user: false,
          project:                          project,
          state:                            'confirmed'
        )
        expect(subject.net_amount.to_f).to eql(89.0)
      end
    end

    context 'with payment service fees paid by user' do
      it 'sums contributions values taking platform_fee out' do
        create(
          :contribution,
          value:                            100,
          payment_method:                   'balanced',
          payment_service_fee:              1,
          payment_service_fee_paid_by_user: true,
          project:                          project,
          state:                            'confirmed'
        )
        expect(subject.net_amount.to_f).to eql(90.0)
      end
    end
  end
end
