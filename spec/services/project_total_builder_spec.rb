require 'spec_helper'

describe ProjectTotalBuilder do
  let!(:project) { create(:project) }
  subject { described_class.new(project) }

  def prepopulate_db
    create(:contribution, value: 10.0, payment_service_fee: 1, state: 'pending', project_id: project.id)
    create(:contribution, value: 10.0, payment_service_fee: 1, state: 'confirmed', project_id: project.id)
    create(:contribution, value: 10.0, payment_service_fee: 1, state: 'waiting_confirmation', project_id: project.id)
    create(:contribution, value: 10.0, payment_service_fee: 1, state: 'refunded', project_id: project.id)
  end

  describe "#pledged" do
    before { prepopulate_db }

    subject { described_class.new(project).attributes[:pledged] }
    it { should == 20 }
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
    it{ should == 2 }
  end

  describe "#total_payment_service_fee" do
    before  { prepopulate_db }
    subject { described_class.new(project).attributes[:total_payment_service_fee] }
    it { should == 2 }
  end

  describe 'net amount' do
    before do
      Configuration.stub(:[]).with(:email_payments).and_return('books@neighbor.ly')
    end

    it 'sums contributions\' net values' do
      create_list(:contribution, 2, value: 100, project: project)
      expect(subject.attributes[:net_amount].to_f).to eql(200.0)
    end
  end

  describe 'platform fee' do
    it 'calculates the amount going to the platform' do
      create(
        :contribution,
        bonds:      2,
        value:      100,
        project_id: project.id,
        state:      'confirmed'
      )
      stub_const('Contribution::FEE_PER_BOND', 3)
      expect(subject.attributes[:platform_fee].to_f).to eql(6.0)
    end
  end
end
