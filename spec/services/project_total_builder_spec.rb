require 'spec_helper'

describe ProjectTotalBuilder do
  let!(:project) { create(:project) }
  before do
    Configuration.stub(:[]).with(:platform_fee).and_return(0.1)
  end
  subject { described_class.new(project) }

  def prepopulate_db
    create(:contribution, value: 10.0, payment_service_fee: 1, state: 'pending', project_id: project.id)
    create(:contribution, value: 10.0, payment_service_fee: 1, state: 'confirmed', project_id: project.id, matching: create(:matching))
    create(:contribution, value: 10.0, payment_service_fee: 1, state: 'confirmed', project_id: project.id)
    create(:contribution, value: 10.0, payment_service_fee: 1, state: 'waiting_confirmation', project_id: project.id)
    create(:contribution, value: 10.0, payment_service_fee: 1, state: 'refunded', project_id: project.id)
    create(:contribution, value: 10.0, payment_service_fee: 1, state: 'requested_refund', project_id: project.id)
  end

  describe "#pledged" do
    before { prepopulate_db }

    subject { described_class.new(project).attributes[:pledged] }
    it { should == 40 }
  end

  describe 'progress' do
    let(:project) { create(:project, goal: 1_000) }

    it 'calculates the reached percentage' do
      subject = described_class.new(project)
      create(:contribution, project: project, value: 730)
      expect(subject.attributes[:progress]).to eql(73)
    end

    it 'allow progress pass of 100%' do
      subject = described_class.new(project)
      create(:contribution, project: project, value: 1_200)
      expect(subject.attributes[:progress]).to eql(120)
    end

    it 'doesn\'t crash when calculating for a project with goal zero' do
      subject = described_class.new(create(:project, goal: 0))
      expect(subject.attributes[:progress]).to eql(0)
    end

    it 'always return integral numbers' do
      project = create(:project, goal: 300)
      subject = described_class.new(project)
      create(:contribution, project: project, value: 200)
      expect(subject.attributes[:progress]).to eql(66)
    end
  end

  describe "#total_contributions" do
    before  { prepopulate_db }
    subject { described_class.new(project).attributes[:total_contributions] }
    it{ should == 4 }
  end

  describe "#total_contributions_without_matches" do
    before  { prepopulate_db }
    subject { described_class.new(project).attributes[:total_contributions_without_matches] }
    it{ should == 3 }
  end

  describe "#total_payment_service_fee" do
    before  { prepopulate_db }
    subject { described_class.new(project).attributes[:total_payment_service_fee] }
    it { should == 3 }
  end

  describe 'net amount' do
    before do
      Configuration.stub(:[]).with(:email_payments).and_return('books@neighbor.ly')
    end

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
        expect(subject.attributes[:net_amount].to_f).to eql(89.0)
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
        expect(subject.attributes[:net_amount].to_f).to eql(90.0)
      end
    end

    it 'takes payment service fees of matches in count' do
      create(:match, project: project, payment_service_fee: 10, value: 1_000, value_unit: 10)
      create(:contribution,
        payment_service_fee: 1,
        value: 50,
        project: project
      )
      expect(subject.attributes[:total_payment_service_fee]).to eql(6) # 1 + 5 from matched contribution
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
      expect(subject.attributes[:platform_fee].to_f).to eql(10.0)
    end
  end
end
