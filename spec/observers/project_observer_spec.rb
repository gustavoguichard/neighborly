require 'spec_helper'

describe ProjectObserver do
  let(:contribution){ create(:contribution, key: 'should be updated', payment_method: 'should be updated', state: 'confirmed', confirmed_at: nil) }
  let(:project) { create(:project, goal: 3000) }
  let(:channel) { create(:channel) }

  subject{ contribution }

  before do
    Configuration[:support_forum] = 'http://support.com'
    Configuration[:email_projects] = 'bar@foo.com'
    Configuration[:email_contact] = 'foo@foo.com'
    Configuration[:facebook_url] = 'http://facebook.com/foo'
    Configuration[:blog_url] = 'http://blog.com/foo'
    Configuration[:company_name] = 'Neighbor.ly'
    Notification.unstub(:notify)
    Notification.unstub(:notify_once)
  end

  describe 'after_create' do
    let(:user) { create(:user, email: ::Configuration[:email_projects])}
    before do
      ProjectObserver.any_instance.should_receive(:after_create).and_call_original
      user
      project
    end

    it 'should create notification for project owner' do
      expect(Notification.where(user_id: project.user.id, template_name: 'project_received', project_id: project.id).first).not_to be_nil
    end

    it 'should create notification for catarse admin' do
      expect(Notification.where(user_id: user.id, template_name: :new_draft_project, project_id: project.id).first).not_to be_nil
    end
  end

  describe 'before_save' do
    let(:channel){ create(:channel) }
    let(:project){ create(:project, video_url: 'http://vimeo.com/11198435', state: 'draft')}

    context 'when project is launched and belongs to a channel' do
      let(:project){ create(:project, video_url: 'http://vimeo.com/11198435', state: 'draft', channels: [channel])}
      before do
        project.update_attributes state: 'draft'
      end

      it 'should call notify using channel data' do
        expect(Notification).to receive(:notify_once).with(
          :project_visible_channel,
          project.user,
          { project_id: project.id, channel_id: channel.id},
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

    context 'when project is launched' do
      before do
        project.update_attributes state: 'draft'
        expect(ProjectDownloaderWorker).to receive(:perform_async).with(project.id).never
      end

      it 'should call notify and do not call download_video_thumbnail' do
        expect(Notification).to receive(:notify_once).with(
          :project_visible,
          project.user,
          { project_id: project.id, channel_id: nil},
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

    context 'when project is approved' do
      before do
        project.update_attributes state: 'draft'
      end

      it 'should call notify_once with project_approved template' do
        expect(Notification).to receive(:notify_once).with(
          :project_approved,
          project.user,
          { project_id: project.id},
          {
            project: project
          }
        )
        project.approve!
      end
    end

    context 'when video_url changes' do
      it 'should call project downloader service and do not call create_notification' do
        expect(ProjectDownloaderWorker).to receive(:perform_async).with(project.id).at_least(1)
        expect(Notification).to receive(:notify).never
        expect(Notification).to receive(:notify_once).never
        project.video_url = 'http://vimeo.com/66698435'
        project.save!
      end
    end
  end

  describe '#notify_owner_that_project_is_waiting_funds' do
    let(:user) { create(:user) }
    let(:project) { create(:project, user: user, goal: 100, online_days: -2, state: 'online') }

    before do
      create(:contribution, project: project, value: 200, state: 'confirmed')
      expect(Notification).to receive(:notify_once).with(
        :project_in_wainting_funds,
        project.user,
        {project_id: project.id},
        {
          project: project
        }
      )
    end

    it('should notify the project owner'){ project.finish }
  end

  describe 'notify_contributors' do

    context 'when project is successful' do
      let(:project){ create(:project, goal: 30, online_days: -7, state: 'online') }
      let(:contribution){ create(:contribution, key: 'should be updated', payment_method: 'should be updated', state: 'confirmed', confirmed_at: Time.now, value: 30, project: project) }

      before do
        contribution
        project.update_attributes state: 'waiting_funds'
        expect(Notification).to receive(:notify_once).at_least(:once)
        contribution.save!
        project.finish!
      end
      it('should notify the project contributions'){ subject }
    end

    context 'when project is unsuccessful' do
      let(:project){ create(:project, goal: 30, online_days: -7, state: 'online') }
      let(:contribution){ create(:contribution, key: 'should be updated', payment_method: 'should be updated', state: 'confirmed', confirmed_at: Time.now, value: 20) }
      before do
        contribution
        project.update_attributes state: 'waiting_funds'
        expect(Notification).to receive(:notify_once).at_least(:once)
        contribution.save!
        project.finish!
      end
      it('should notify the project contributions and owner'){ subject }
    end

    context 'when project is unsuccessful with pending contributions' do
      let(:project){ create(:project, goal: 30, online_days: -7, state: 'online') }

      before do
        create(:contribution, project: project, key: 'ABC1', payment_method: 'ABC', payment_token: 'ABC', value: 20, state: 'confirmed')
        create(:contribution, project: project, key: 'ABC2', payment_method: 'ABC', payment_token: 'ABC', value: 20)
        project.update_attributes state: 'waiting_funds'
      end

      before do
        expect(Notification).to receive(:notify_once).at_least(3)
        project.finish!
      end
      it('should notify the project contributions and owner'){ subject }
    end

  end

  describe '#notify_owner_that_project_is_successful' do
    let(:project){ create(:project, goal: 30, online_days: -7, state: 'waiting_funds') }

    before do
      project.stub(:reached_goal?).and_return(true)
      project.stub(:in_time_to_wait?).and_return(false)
      project.finish
    end

    it 'should create notification for project owner' do
      expect(Notification.where(user_id: project.user.id, template_name: 'project_success', project_id: project.id).first).not_to be_nil
    end
  end

  describe '#notify_owner_that_project_is_online' do
    let(:project) { create(:project, state: 'draft') }

    context 'when project don\'t belong to any channel' do
      before do
        project.launch!
      end

      it 'should create notification for project owner' do
        expect(Notification.where(user_id: project.user.id, template_name: 'project_visible', project_id: project.id).first).not_to be_nil
      end
    end

    context 'when project belong to a channel' do
      before do
        project.channels << channel
        project.launch!
      end

      it 'should create notification for project owner' do
        expect(Notification.where(user_id: project.user.id, template_name: 'project_visible_channel', project_id: project.id).first).not_to be_nil
      end
    end
  end

  describe '#notify_owner_that_project_is_rejected' do
    let(:project){ create(:project, state: 'draft') }

    context 'when project don\'t belong to any channel' do
      before do
        project.reject
      end
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
    let(:user) { create(:user, email: 'foo@foo.com')}
    before do
      Configuration[:email_payments] = 'foo@foo.com'
      Configuration[:email_system] = 'foo2@foo.com'
      user
      project.stub(:reached_goal?).and_return(true)
      project.stub(:in_time_to_wait?).and_return(false)
      project.finish
    end

    it 'should create notification for admin' do
      expect(Notification.where(user_id: user.id, template_name: 'adm_project_deadline', project_id: project.id).first).not_to be_nil
    end

  end

end
