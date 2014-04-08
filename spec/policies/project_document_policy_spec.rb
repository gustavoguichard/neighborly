require 'spec_helper'

describe ProjectDocumentPolicy do
  subject { described_class }

  let(:policy) { described_class.new(user, project_document) }
  let(:user) { nil }
  let(:project_document) { create(:project_document) }

  shared_examples_for 'create permissions' do
    it 'should deny access if user is nil' do
      expect(subject).not_to permit(nil, project_document)
    end

    it 'should deny access if user is not project owner' do
      expect(subject).not_to permit(User.new, project_document)
    end

    it 'should permit access if user is project owner' do
      new_user = project_document.project.user
      expect(subject).to permit(new_user, project_document)
    end

    it 'should permit access if user is admin' do
      admin = build(:user, admin: true)
      expect(subject).to permit(admin, project_document)
    end

    it 'should permit access if user is a channel member' do
      channel = Channel.new
      user = User.new
      user.channels = [channel]
      project = Project.new
      project.channels = [channel]
      should permit(user, ProjectDocument.new(project: project))
    end

    it 'should permit access if user is the channel owner' do
      user = User.new
      channel = Channel.new(user: user)
      project = Project.new
      project.channels = [channel]
      should permit(user, ProjectDocument.new(project: project))
    end
  end

  permissions :create? do
    it_should_behave_like 'create permissions'
  end

  permissions :destroy? do
    it_should_behave_like 'create permissions'
  end

  describe '#permitted?' do
    let(:policy){ described_class.new(nil, ProjectDocument.new) }

    ProjectDocument.attribute_names.each do |field|
      it "when field is #{field}" do
        expect(policy.permitted?(field.to_sym)).to be_true
      end
    end
  end
end
