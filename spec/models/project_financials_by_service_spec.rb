require 'spec_helper'

describe ProjectFinancialsByService do
  describe 'net amount' do
    context 'with payment service fees paid by project owner' do
      it 'sums contributions values taking platform_fee and payment_service_fee out' do
        create(
          :contribution,
          value:                            100,
          payment_service_fee:              1,
          payment_service_fee_paid_by_user: false,
          project_id:                       project.id,
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
          payment_service_fee:              1,
          payment_service_fee_paid_by_user: true,
          project_id:                       project.id,
          state:                            'confirmed'
        )
        expect(subject.net_amount.to_f).to eql(90.0)
      end
    end
  end
end
