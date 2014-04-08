require 'spec_helper'

describe RewardPolicy do
  subject { described_class }

  let(:policy) { described_class.new(user, reward) }
  let(:user) { nil }
  let(:reward) { create(:reward) }

  shared_examples_for 'create permissions' do
    it 'should deny access if user is nil' do
      expect(subject).not_to permit(nil, reward)
    end

    it 'should deny access if user is not project owner' do
      expect(subject).not_to permit(User.new, reward)
    end

    it 'should permit access if user is project owner' do
      new_user = reward.project.user
      expect(subject).to permit(new_user, reward)
    end

    it 'should permit access if user is admin' do
      admin = build(:user, admin: true)
      expect(subject).to permit(admin, reward)
    end

    it 'should permit access if user is a channel member' do
      channel = Channel.new
      user = User.new
      user.channels = [channel]
      project = Project.new
      project.channels = [channel]
       expect(subject).to  permit(user, Reward.new(project: project))
    end

    it 'should permit access if user is the channel owner' do
      user = User.new
      channel = Channel.new(user: user)
      project = Project.new
      project.channels = [channel]
       expect(subject).to  permit(user, Reward.new(project: project))
    end
  end

  shared_examples_for 'destroy permissions' do
    it_should_behave_like 'create permissions'

    it 'should deny access if reward has one contribution waiting for confirmation' do
      create(:contribution, project: reward.project, reward: reward, state: 'waiting_confirmation')
      expect(subject).not_to permit(reward.project.user, reward)
    end

    it 'should deny access if reward has one confirmed contribution' do
      create(:contribution, project: reward.project, reward: reward, state: 'confirmed')
      expect(subject).not_to permit(reward.project.user, reward)
    end
  end

  permissions :new? do
    it_should_behave_like 'create permissions'
  end

  permissions :create? do
    it_should_behave_like 'create permissions'
  end

  permissions :edit? do
    it_should_behave_like 'create permissions'
  end

  permissions :update? do
    it_should_behave_like 'create permissions'
  end

  permissions :sort? do
    it_should_behave_like 'create permissions'
  end

  permissions :destroy? do
    it_should_behave_like 'destroy permissions'
  end

  describe '#permitted_for?' do
    let(:user) { reward.project.user }
    subject { policy.permitted_for?(field, :update) }

    ['waiting_confirmation', 'confirmed'].each do |state|
      context "when we have one contribution in state #{state}" do
        before do
          create(:contribution, project: reward.project, reward: reward, state: 'waiting_confirmation')
        end

        context 'and want to update minimum_value' do
          let(:field) { :minimum_value }
          it { expect(subject).to be_false }
        end

        context 'and want to update description' do
          let(:field) { :description }
          it { expect(subject).to be_true }
        end

        context 'and want to update maximum_contributions' do
          let(:field) { :maximum_contributions }
          it { expect(subject).to be_true }
        end

        context 'and want to update days_to_delivery' do
          let(:field) { :days_to_delivery }
          it { expect(subject).to be_true }
        end
      end
    end

    ['failed', 'successful'].each do |state|
      context "when reward's project is in state #{state}" do
        let(:reward) { create(:reward, project: create(:project, state: state)) }
        context 'and want to update minimum_value' do
          let(:field) { :minimum_value }
          it { expect(subject).to be_true }
        end

        context 'and want to update description' do
          let(:field) { :description }
          it { expect(subject).to be_true }
        end

        context 'and want to update maximum_contributions' do
          let(:field) { :maximum_contributions }
          it { expect(subject).to be_true }
        end

        context 'and want to update days_to_delivery' do
          let(:field) { :days_to_delivery }
          it { expect(subject).to be_false }
        end
      end
    end

    context 'when reward\'s project is in state online' do
      let(:reward) { create(:reward, project: create(:project, state: 'online')) }
      context 'and want to update minimum_value' do
        let(:field) { :minimum_value }
        it { expect(subject).to be_true }
      end

      context 'and want to update description' do
        let(:field) { :description }
        it { expect(subject).to be_true }
      end

      context 'and want to update maximum_contributions' do
        let(:field) { :maximum_contributions }
        it { expect(subject).to be_true }
      end

      context 'and want to update days_to_delivery' do
        let(:field) { :days_to_delivery }
        it { expect(subject).to be_true }
      end
    end
  end
end
