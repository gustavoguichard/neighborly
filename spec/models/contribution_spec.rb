require 'spec_helper'

describe Contribution do
  let(:user){ create(:user) }
  let(:failed_project){ create(:project, state: 'online') }
  let(:unfinished_project){ create(:project, state: 'online') }
  let(:successful_project){ create(:project, state: 'online') }
  let(:unfinished_project_contribution){ create(:contribution, state: 'confirmed', user: user, project: unfinished_project) }
  let(:sucessful_project_contribution){ create(:contribution, state: 'confirmed', user: user, project: successful_project) }
  let(:not_confirmed_contribution){ create(:contribution, user: user, project: unfinished_project) }
  let(:valid_refund){ create(:contribution, state: 'confirmed', user: user, project: failed_project) }


  describe 'associations' do
    it { should have_many(:notifications) }
    it { should belong_to(:project) }
    it { should belong_to(:user) }
    it { should belong_to(:reward) }
    it { should belong_to(:matching) }
  end

  describe 'validations' do
    it{ should validate_presence_of(:project) }
    it{ should validate_presence_of(:user) }
    it{ should validate_presence_of(:value) }
    it{ should_not allow_value(9.99).for(:value) }
    it{ should allow_value(10).for(:value) }
    it{ should allow_value(20).for(:value) }
  end

  describe '#pg_search' do
    context 'using payment_method' do
      let(:contribution) { create(:contribution, payment_method: 'balanced') }

      context 'when contribution exists' do
        it 'returns the contribution ignoring accents' do
          expect(
            [described_class.pg_search('balanced'), described_class.pg_search('bálançed')]
          ).to eq [[contribution], [contribution]]
        end
      end

      context 'when contribution is not found' do
        it 'returns a empty array' do
          expect(described_class.pg_search('lorem')).to eq []
        end
      end
    end

    context 'using user name' do
      let(:contribution) do
        create(:contribution, user: create(:user, name: 'Foo Bar User'))
      end

      it 'returns the contribution' do
        expect(described_class.pg_search('Foo Bar User')).to eq [contribution]
      end
    end

    context 'using user email' do
      let(:contribution) do
        create(:contribution, user: create(:user, email: 'foobar@contribution.com'))
      end

      it 'returns the contribution' do
        expect(described_class.pg_search('foobar@contribution.com')).to eq [contribution]
      end
    end

    context 'using project name' do
      let(:contribution) do
        create(:contribution, project: create(:project, name: 'Foo Bar Project', state: 'online'))
      end

      it 'returns the contribution' do
        expect(described_class.pg_search('Foo Bar Project')).to eq [contribution]
      end
    end
  end

  pending '.confirmed_today' do
    before do
      3.times { create(:contribution, state: 'confirmed', confirmed_at: 2.days.ago) }
      4.times { create(:contribution, state: 'confirmed', confirmed_at: 6.days.ago) }

      #TODO: need to investigate this timestamp issue when
      # use DateTime.now or Time.now
      7.times { create(:contribution, state: 'confirmed', confirmed_at: 5.hours.from_now) }
    end

    subject { Contribution.confirmed_today }

    it { should have(7).items }
  end

  describe '.can_cancel' do
    subject { Contribution.can_cancel}

    context 'when contribution is in time to wait the confirmation' do
      before do
        create(:contribution, state: 'waiting_confirmation', created_at: 3.weekdays_ago)
      end
      it { should have(0).item }
    end

    context 'when we have contributions that is passed the confirmation time' do
      before do
        create(:contribution, state: 'waiting_confirmation', created_at: 3.weekdays_ago)
        create(:contribution, state: 'waiting_confirmation', created_at: 7.weekdays_ago)
      end
      it { should have(1).itens }
    end
  end

  describe '#recommended_projects' do
    subject{ contribution.recommended_projects }
    let(:contribution){ create(:contribution) }

    context 'when we have another projects in the same category' do
      before do
        @recommended = create(:project, category: contribution.project.category)
        # add a project successful that should not apear as recommended
        create(:project, category: contribution.project.category, state: 'successful')
      end
      it{ should eq [@recommended] }
    end

    context 'when another user has contributed the same project' do
      before do
        @another_contribution = create(:contribution, project: contribution.project)
        @recommended = create(:contribution, user: @another_contribution.user).project
        # add a project successful that should not apear as recommended
        create(:contribution, user: @another_contribution.user, project: successful_project)
        successful_project.update_attributes state: 'successful'
      end
      it{ should eq [@recommended] }
    end
  end


  describe '.can_refund' do
    subject{ Contribution.can_refund.load }
    before do
      create(:contribution, state: 'confirmed', credits: true, project: failed_project)
      valid_refund
      sucessful_project_contribution
      unfinished_project
      not_confirmed_contribution
      successful_project.update_attributes state: 'successful'
      failed_project.update_attributes state: 'failed'
    end
    it{ should == [valid_refund] }
  end

  describe '#credits' do
    subject{ user.credits.to_f }
    context 'when contributions are confirmed and not done with credits but project is successful' do
      before do
        create(:contribution, state: 'confirmed', user: user, project: successful_project)
        successful_project.update_attributes state: 'successful'
      end
      it{ should == 0 }
    end

    context 'when contributions are confirmed and not done with credits' do
      before do
        create(:contribution, state: 'confirmed', user: user, project: failed_project)
        failed_project.update_attributes state: 'failed'
      end
      it{ should == 10 }
    end

    context 'when contributions are done with credits' do
      before do
        create(:contribution, credits: true, state: 'confirmed', user: user, project: failed_project)
        failed_project.update_attributes state: 'failed'
      end
      it{ should == 0 }
    end

    context 'when contributions are not confirmed' do
      before do
        create(:contribution, user: user, project: failed_project, state: 'pending')
        failed_project.update_attributes state: 'failed'
      end
      it{ should == 0 }
    end
  end

  describe '#display_value' do
    context 'when the value has decimal places' do
      subject{ build(:contribution, value: 99.99).display_value }
      it{ should == '$99.99' }
    end

    context 'when the value does not have decimal places' do
      subject{ build(:contribution, value: 1).display_value }
      it{ should == '$1.00' }
    end
  end

  describe 'when saving' do
    it 'generates matched contributions' do
      expect_any_instance_of(MatchedContributionGenerator).to receive(:create)
      create(:contribution)
    end

    it 'skips matched contributions generation when is already a match' do
      expect_any_instance_of(MatchedContributionGenerator).to_not receive(:create)
      create(:contribution, payment_method: :matched)
    end
  end

  describe 'as json' do
    subject { build(:contribution) }

    it 'returns ActiveRecord\'s implementation when an option is given' do
      expect(subject).to receive(:serializable_hash)
      subject.as_json(only: :name)
    end

    it 'returns PayableResourceSerializer\'s implementation when an option is given' do
      expect_any_instance_of(PayableResourceSerializer).to receive(:to_json)
      subject.as_json
    end
  end

  describe 'net value' do
    subject do
      build(:contribution, value: 100, payment_service_fee: 1)
    end

    it 'is equal to contribution value when user paid service fees' do
      subject.payment_service_fee_paid_by_user = true
      expect(subject.net_value).to eql(100)
    end

    it 'is equal to contribution value minus service fees when project paid them' do
      subject.payment_service_fee_paid_by_user = false
      expect(subject.net_value).to eql(99)
    end
  end
end
