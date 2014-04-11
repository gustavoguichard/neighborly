require 'spec_helper'

describe ProjectPolicy do
  subject{ described_class }

  shared_examples_for 'create permissions' do
    let(:project_state) { 'draft' }

    it 'should deny access if user is nil' do
      should_not permit(nil, Project.new(state: project_state))
    end

    it 'should deny access if user is not project owner' do
      should_not permit(User.new, Project.new(state: project_state,
                                              user: User.new))
    end

    it 'should permit access if user is project owner' do
      new_user = User.new
      should permit(new_user, Project.new(state: project_state,
                                          user: new_user))
    end

    it 'should permit access if user is admin' do
      admin = User.new
      admin.admin = true
      should permit(admin, Project.new(state: project_state,
                                       user: User.new))
    end

    it 'should permit access if user is a channel member' do
      channel = Channel.new
      user = User.new
      user.channels = [channel]
      project = Project.new state: project_state
      project.channels = [channel]
      should permit(user, project)
    end

    it 'should permit access if user is the channel owner' do
      user = User.new
      channel = Channel.new(user: user)
      project = Project.new state: project_state
      project.channels = [channel]
      should permit(user, project)
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

  permissions :success? do
    it_should_behave_like 'create permissions'
  end

  permissions :reports? do
    it_should_behave_like 'create permissions'
  end

  permissions :show? do
    context 'when project is in draft' do
      let(:project_state) { 'draft' }
      it_should_behave_like 'create permissions'
    end

    context 'when project is in soon' do
      let(:project_state) { 'soon' }
      it_should_behave_like 'create permissions'
    end

    context 'when project is online' do
      let(:project_state) { 'online' }

      it 'should permit access if user is nil' do
        should permit(nil, Project.new(state: project_state))
      end

      it 'should permit access if user is not project owner' do
        should permit(User.new, Project.new(state: project_state,
                                             user: User.new))
      end
    end
  end

  describe '#permitted_for?' do
    context 'when user is nil and I want to update about' do
      let(:policy){ described_class.new(nil, Project.new) }
      subject{ policy.permitted_for?(:about, :update) }
      it{ should be_false }
    end

    context 'when user is project owner and I want to update about' do
      let(:project){ create(:project) }
      let(:policy){ described_class.new(project.user, project) }
      subject{ policy.permitted_for?(:about, :update) }
      it{ should be_true }
    end
  end

  describe '#permitted_for?' do
    context 'when user is nil and I want to update about' do
      let(:policy){ described_class.new(nil, Project.new) }
      subject{ policy.permitted_for?(:about, :update) }
      it{ should be_false }
    end

    context 'when user is project owner and I want to update about' do
      let(:project){ create(:project) }
      let(:policy){ described_class.new(project.user, project) }
      subject{ policy.permitted_for?(:about, :update) }
      it{ should be_true }
    end
  end

  describe '#permitted?' do
    context 'when user is nil' do
      let(:policy){ described_class.new(nil, Project.new) }

      [:about,         :video_url,            :uploaded_image,
       :hero_image,    :headline,             :budget,
       :terms,         :address_neighborhood, :address,
       :address_city,  :address_state,        :hash_tag,
       :site, :tag_list].each do |field|
        context "when field is #{field}" do
          subject{ policy.permitted?(field) }
          it{ should be_true }
        end
      end

      context 'when field is title' do
        subject{ policy.permitted?(:title) }
        it{ should be_false }
      end
    end

    context 'when user is admin' do
      let(:user){ create(:user, admin: true) }
      let(:project){ create(:project) }
      let(:policy){ described_class.new(user, project) }

      (Project.attribute_names + ['address']).each do |field|
        context "when field is #{field}" do
          subject{ policy.permitted?(field.to_sym) }
          it{ should be_true }
        end
      end
    end
  end
end
