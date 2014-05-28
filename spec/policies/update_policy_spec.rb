require 'spec_helper'

describe UpdatePolicy do
  subject { described_class }

  let(:policy) { described_class.new(user, update) }
  let(:user) { nil }
  let(:update) { create(:update) }

  shared_examples_for 'create permissions' do
    it 'should deny access if user is nil' do
      expect(subject).not_to permit(nil, update)
    end

    it 'should deny access if user is not project owner' do
      expect(subject).not_to permit(User.new, update)
    end

    it 'should permit access if user is project owner' do
      new_user = update.project.user
      expect(subject).to permit(new_user, update)
    end

    it 'should permit access if user is admin' do
      admin = build(:user, admin: true)
      expect(subject).to permit(admin, update)
    end

    it 'should permit access if user is a channel member' do
      channel = Channel.new
      user = User.new
      user.channels = [channel]
      project = Project.new
      project.channels = [channel]
      should permit(user, Update.new(project: project))
    end

    it 'should permit access if user is the channel owner' do
      user = User.new
      channel = Channel.new(user: user)
      project = Project.new
      project.channels = [channel]
      should permit(user, Update.new(project: project))
    end
  end

  permissions :create? do
    it_should_behave_like 'create permissions'
  end

  permissions :destroy? do
    it_should_behave_like 'create permissions'
  end

  describe '#permitted?' do
    let(:policy){ described_class.new(nil, Update.new) }

    Update.attribute_names.each do |field|
      it "when field is #{field}" do
        expect(policy.permitted?(field.to_sym)).to be_true
      end
    end
  end

  describe 'Scope' do
    describe '.resolve' do
      let(:project)           { create(:project) }
      let(:user)              { }
      let!(:exclusive_update) { create(:update, exclusive: true, project: project) }
      let!(:update)           { create(:update, project: project) }

      subject { UpdatePolicy::Scope.new(user, project.updates).resolve }

      context 'when user is a contributor' do
        let(:user) { create(:contribution, state: 'confirmed', project: project).user }

        it 'includes all updates' do
          expect(subject).to include(exclusive_update, update)
        end
      end

      context 'when user is not a contributor' do
        let(:user) { create(:contribution, state: 'pending', project: project).user }

        it 'returns the non-exclusive update' do
          expect(subject).to eq [update]
        end
      end

      context 'when user is a project owner' do
        let(:user) { project.user }

        it 'includes all updates' do
          expect(subject).to include(exclusive_update, update)
        end
      end

      context 'when user is an admin' do
        let(:user) { create(:user, admin: true) }

        it 'includes all updates' do
          expect(subject).to include(exclusive_update, update)
        end
      end

      context 'when user is a guest' do
        it 'returns the non-exclusive update' do
          expect(subject).to eq [update]
        end
      end
    end
  end
end
