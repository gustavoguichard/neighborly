require 'spec_helper'

describe ContributionPolicy do
  subject{ described_class }

  let(:project) { create(:project) }
  let(:contribution) { create(:contribution) }
  let(:user) { contribution.user }

  shared_examples_for 'update permissions' do
    it 'denies access if user is nil' do
      expect(subject).not_to permit(nil, contribution)
    end

    it 'denies access if user is not updating his contribution' do
      expect(subject).not_to permit(User.new, contribution)
    end

    it 'authorizes access if user is contribution owner' do
      expect(subject).to permit(user, contribution)
    end

    it 'authorizes access if user is admin' do
      admin = build(:user, admin: true)
      expect(subject).to permit(admin, contribution)
    end
  end

  shared_examples_for 'create permissions' do
    it_should_behave_like 'update permissions'

    ['draft', 'deleted', 'rejected', 'successful', 'failed', 'waiting_funds'].each do |state|
      it "denies access if project is on #{state}" do
        contribution.project.update_attributes state: state
        expect(subject).not_to permit(user, contribution)
      end
    end
  end

  permissions(:new?) { it_should_behave_like 'create permissions' }

  permissions(:create?) { it_should_behave_like 'create permissions' }

  permissions(:show?) { it_should_behave_like 'update permissions' }

  permissions(:update?) { it_should_behave_like 'update permissions' }

  permissions(:edit?) { it_should_behave_like 'update permissions' }

  permissions(:credits_checkout?) { it_should_behave_like 'update permissions' }

  permissions(:request_refund?) { it_should_behave_like 'update permissions' }

  describe 'UserScope' do
    describe '.resolve' do
      let(:current_user) { create(:user, admin: false) }
      let(:user) { nil }
      before do
        @contribution = create(:contribution, anonymous: false, state: 'confirmed', project: project)
        @anon_contribution = create(:contribution, anonymous: true, state: 'confirmed', project: project)
      end

      subject { described_class::UserScope.new(current_user, user, project.contributions).resolve.order('created_at desc') }

      context 'when user is admin' do
        let(:current_user) { create(:user, admin: true) }

        it { expect(subject).to have(2).itens }
      end

      context 'when user is a contributor' do
        let(:current_user) { user }
        it { expect(subject).to eq [@anon_contribution, @contribution] }
      end

      context 'when user is not an admin' do
        it { expect(subject).to eq [@contribution] }
      end
    end
  end

  describe '#permitted?' do
    let(:policy) { described_class.new(user, build(:contribution)) }
    subject{ policy }

    %i[user_attributes
       user_id
       state
       user
       payment_service_fee
       payment_id
       payment_service_fee_paid_by_user].each do |field|
      it { expect(subject).not_to be_permitted(field) }
    end

    %i[value].each do |field|
      it { expect(subject).to be_permitted(field) }
    end
  end

end
