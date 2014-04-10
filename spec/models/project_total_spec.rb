require 'spec_helper'

describe ProjectTotal do
  let!(:project) { create(:project) }
  before { Configuration[:platform_fee] = 0.1 }
  subject do
    ProjectTotal.find_by(project_id: project)
  end

  def prepopulate_db
    create(:contribution, value: 10.0, payment_service_fee: 1, state: 'pending', project_id: project.id)
    create(:contribution, value: 10.0, payment_service_fee: 1, state: 'confirmed', project_id: project.id)
    create(:contribution, value: 10.0, payment_service_fee: 1, state: 'waiting_confirmation', project_id: project.id)
    create(:contribution, value: 10.0, payment_service_fee: 1, state: 'refunded', project_id: project.id)
    create(:contribution, value: 10.0, payment_service_fee: 1, state: 'requested_refund', project_id: project.id)
  end

  describe "#pledged" do
    before { prepopulate_db }

    subject{ ProjectTotal.where(project_id: project.id).first.pledged }
    it{ should == 30 }
  end

  describe "#total_contributions" do
    before { prepopulate_db }
    subject{ ProjectTotal.where(project_id: project.id).first.total_contributions }
    it{ should == 3 }
  end

  describe "#total_payment_service_fee" do
    before { prepopulate_db }
    subject { ProjectTotal.where(project_id: project.id).first.total_payment_service_fee }
    it { should == 3 }
  end

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

  describe 'platform fee' do
    it 'calculates the amount going to the platform' do
      create(
        :contribution,
        value:      100,
        project_id: project.id,
        state:      'confirmed'
      )
      expect(subject.platform_fee.to_f).to eql(10.0)
    end
  end
end
