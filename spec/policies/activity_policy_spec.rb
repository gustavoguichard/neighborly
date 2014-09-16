require 'spec_helper'

describe ActivityPolicy do
  subject { described_class }

  let(:policy) { described_class.new(user, activity) }
  let(:user) { nil }
  let(:activity) { create(:activity) }

  shared_examples_for 'create permissions' do
    it 'should deny access if user is nil' do
      expect(subject).not_to permit(nil, activity)
    end

    it 'should deny access if user is not project owner' do
      expect(subject).not_to permit(User.new, activity)
    end

    it 'should permit access if user is project owner' do
      new_user = activity.project.user
      expect(subject).to permit(new_user, activity)
    end

    it 'should permit access if user is admin' do
      admin = build(:user, admin: true)
      expect(subject).to permit(admin, activity)
    end

    it 'should permit access if user is a channel member' do
      channel = Channel.new
      user = User.new
      user.channels = [channel]
      project = Project.new
      project.channels = [channel]
       expect(subject).to  permit(user, Activity.new(project: project))
    end

    it 'should permit access if user is the channel owner' do
      user = User.new
      channel = Channel.new(user: user)
      project = Project.new
      project.channels = [channel]
       expect(subject).to  permit(user, Activity.new(project: project))
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

  permissions :destroy? do
    it_should_behave_like 'create permissions'
  end

  describe '#permitted_for?' do
    let(:user) { activity.project.user }

    [:title, :happened_at, :summary].each do |field|
      it "permits param #{field}" do
        policy.permitted_for?(field, :update)
      end
    end

  end
end
