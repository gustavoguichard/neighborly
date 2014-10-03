require 'spec_helper'

describe ProjectObserver do
  let(:project) { create(:project, goal: 3000) }

  subject { contribution }

  before do
    ProjectObserver.any_instance.unstub(:deliver_default_notification_for)
    ProjectObserver.any_instance.unstub(:notify_new_draft_project)
    Notification.unstub(:notify_once)
  end

  describe '#after_create' do
    let!(:user) { create(:user, email: ::Configuration[:email_projects].dup)}

    it 'creates notification for project owner' do
      project
      expect(
        Notification.where(user_id: project.user.id,
                           template_name: 'project_received',
                           project_id: project.id).first
      ).not_to be_nil
    end

    it 'creates notification for admins' do
      project
      expect(
        Notification.where(user_id: user.id,
                           template_name: 'new_draft_project',
                           project_id: project.id).first
      ).not_to be_nil
    end

    it 'creates a project total' do
      builder = double('ProjectTotalBuilder')
      allow(ProjectTotalBuilder).to receive(:new).and_return(builder)
      expect(builder).to receive(:perform).at_least(:once)
      project
    end
  end

  describe '#after_save' do
    context 'when video_url changes' do
      it 'calls project downloader service' do
        expect(ProjectDownloaderWorker).to receive(:perform_async).with(project.id)
        project.update(video_url: 'http://vimeo.com/66698435')
      end
    end
  end

  describe 'after updating' do
    it 'updates project total' do
      project
      expect_any_instance_of(ProjectTotalBuilder).to receive(:perform)
      project.update_attributes(goal: 25_000)
    end
  end

  describe '#from_draft_to_soon' do
    before { project.update_attributes state: 'draft' }

    it 'calls notify_once with project_approved template' do
      expect(Notification).to receive(:notify_once).with(
        :project_approved,
        project.user,
        { project_id: project.id },
        { project: project }
      )
      project.approve!
    end
  end

  describe '#from_soon_to_online' do
    before { project.update_attributes state: 'soon' }

    it 'calls from_draft_to_online' do
      expect_any_instance_of(
        ProjectObserver
      ).to receive(:from_draft_to_online).with(project)

      project.launch!
    end
  end

  describe '#from_online_to_waiting_funds' do
    let(:user)    { create(:user) }
    let(:project) { create(:project, user: user, goal: 100, online_days: -2, state: 'online') }

    before do
      create(:contribution, project: project, value: 200, state: 'confirmed')
    end

    it 'notifies the project owner' do
      expect(project).to receive(:notify_owner).with(:project_in_wainting_funds)
      project.finish!
    end
  end

  describe '#from_draft_to_online' do
    let(:project) { create(:project, state: 'draft') }

    it 'notifies the project owner' do
      expect(Notification).to receive(:notify_once).with(
        :project_visible,
        project.user,
        { project_id: project.id },
        {
          project: project,
          origin_email: Configuration[:email_contact],
          origin_name: Configuration[:company_name]
        }
      )
      project.launch!
    end
  end

  describe '#from_draft_to_rejected' do
    let(:project){ create(:project, state: 'draft') }
    before { project.reject! }

    it 'should create notification for project owner' do
      expect(Notification.where(user_id: project.user.id, template_name: 'project_rejected', project_id: project.id).first).not_to be_nil
    end
  end
end
