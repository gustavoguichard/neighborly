require 'spec_helper'

describe ProjectObserver do
  let(:project) { create(:project, goal: 3000) }
  let(:channel) { create(:channel) }

  subject { contribution }

  before do
    Notification.unstub(:notify)
    Notification.unstub(:notify_once)
  end

  describe '#after_create' do
    let(:user) { create(:user, email: ::Configuration[:email_projects].dup)}
    before do
      ProjectObserver.any_instance.should_receive(:after_create).and_call_original
      user
      project
    end

    it 'creates notification for project owner' do
      expect(
        Notification.where(user_id: project.user.id,
                           template_name: 'project_received',
                           project_id: project.id).first
      ).not_to be_nil
    end

    it 'creates notification for admins' do
      expect(
        Notification.where(user_id: user.id,
                           template_name: 'new_draft_project',
                           project_id: project.id).first
      ).not_to be_nil
    end
  end

  describe '#before_save' do
    context 'when video_url changes' do
      it 'calls project downloader service' do
        expect(ProjectDownloaderWorker).to receive(:perform_async).with(project.id)
        project.update(video_url: 'http://vimeo.com/66698435')
      end
    end
  end

  describe '#from_online_to_failed' do
    let(:project) do
      create(:project, goal: 30, online_days: -7, state: 'online')
    end

    let!(:contribution) do
      create(:contribution,
             project: project,
             state: 'confirmed',
             confirmed_at: Time.now,
             value: 20)
    end

    before { project.update_attributes state: 'waiting_funds' }

    it 'notifies the project contributors and owner' do
      expect(Notification).to receive(:notify_once).at_least(2)
      project.finish!
    end

    context 'when with pending contributions' do
      before do
        project.update_attributes state: 'online'
        create(:contribution, project: project, value: 20, state: 'pending')
        project.update_attributes state: 'waiting_funds'
      end

      it 'ignores the pending contribution' do
        expect(Notification).to receive(:notify_once).at_least(2)
        project.finish!
      end
    end
  end

  describe '#from_waiting_funds_to_failed' do
    let(:project) do
      create(:project, goal: 30, online_days: -7, state: 'waiting_funds')
    end

    it 'calls from_online_to_failed' do
      expect_any_instance_of(
        ProjectObserver
      ).to receive(:from_online_to_failed).with(project)

      project.finish!
    end

    it 'calls notify_admin_that_project_reached_deadline' do
      expect_any_instance_of(
        ProjectObserver
      ).to receive(:notify_admin_that_project_reached_deadline).with(project)

      project.finish!
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

  describe '#from_waiting_funds_to_successful' do
    let(:project){ create(:project, goal: 30, online_days: -7, state: 'waiting_funds') }

    before do
      project.stub(:reached_goal?).and_return(true)
      project.stub(:in_time_to_wait?).and_return(false)
    end

    it 'notifies the project owner' do
      expect(project).to receive(:notify_owner).with(:project_success)
      project.finish!
    end

    it 'calls notify_admin_that_project_reached_deadline' do
      expect_any_instance_of(ProjectObserver).to receive(
        :notify_admin_that_project_reached_deadline
      ).with(project)

      project.finish!
    end

    it 'calls notify_users' do
      expect_any_instance_of(ProjectObserver).to receive(:notify_users).with(project)
      project.finish!
    end
  end

  describe '#from_draft_to_online' do
    let(:project) { create(:project, state: 'draft') }

    context "when project don't belongs to any channel" do
      it 'notifies the project owner' do
        expect(Notification).to receive(:notify_once).with(
          :project_visible,
          project.user,
          { project_id: project.id, channel_id: nil },
          {
            project: project,
            channel: nil,
            origin_email: Configuration[:email_contact],
            origin_name: Configuration[:company_name]
          }
        )
        project.launch!
      end
    end

    context 'when project belongs to a channel' do
      before { project.channels << channel }

      it 'notifies the project owner' do
        expect(Notification).to receive(:notify_once).with(
          :project_visible_channel,
          project.user,
          { project_id: project.id, channel_id: channel.id },
          {
            project: project,
            channel: channel,
            origin_email: channel.user.email,
            origin_name: channel.name
          }
        )
        project.launch!
      end
    end
  end

  describe '#from_draft_to_rejected' do
    let(:project){ create(:project, state: 'draft') }

    context 'when project don\'t belong to any channel' do
      before { project.reject! }

      it 'should create notification for project owner' do
        expect(Notification.where(user_id: project.user.id, template_name: 'project_rejected', project_id: project.id).first).not_to be_nil
      end
    end

    context 'when project belong to a channel' do
      before do
        project.channels << channel
        project.reject
      end

      it 'should create notification for project owner' do
        expect(Notification.where(user_id: project.user.id, template_name: 'project_rejected_channel', project_id: project.id).first).not_to be_nil
      end
    end
  end

  describe '#notify_admin_that_project_reached_deadline' do
    let(:project){ create(:project, goal: 30, online_days: -7, state: 'waiting_funds') }
    let!(:user) { create(:user, email: Configuration[:email_payments].dup)}
    before do
      project.stub(:reached_goal?).and_return(true)
      project.stub(:in_time_to_wait?).and_return(false)
      project.finish
    end

    it 'should create notification for admin' do
      expect(Notification.where(user_id: user.id, template_name: 'adm_project_deadline', project_id: project.id).first).not_to be_nil
    end
  end
end
