require 'spec_helper'

describe ContributionObserver do
  let(:resource) do
    create(:contribution,
           state: default_state,
           confirmed_at: confirmed_at,
           value: 1000)
  end
  let(:resource_class)   { Contribution }

  let(:resource_name)    { resource_class.model_name.param_key.to_sym }
  let(:resource_id_name) { "#{resource_name}_id".to_sym }
  let(:default_state)    { 'confirmed' }
  let(:confirmed_at)     { Time.now }

  before do
    Notification.unstub(:notify)
    Notification.unstub(:notify_once)
  end

  describe '#after_create' do
    it 'calls #define_key!' do
      expect_any_instance_of(resource_class).to receive(:define_key!)
      create(resource_name)
    end

    describe 'when updating status' do
      let(:default_state) { 'pending' }

      it 'updates matched contributions\' statuses' do
        expect_any_instance_of(MatchedContributionGenerator).to receive(:update)
        resource.confirm!
      end
    end
  end

  describe '#before_save' do
    context 'when project reached the goal' do
      let(:project){ create(:project, state: 'failed', goal: 1000) }

      before do
        project.stub(:project_total).and_return(
          double('ProjectTotal', pledged: 1000.0, total_contributions: 1)
        )
        resource.project = project
      end

      it 'notifies the project owner' do
        expect(Notification).to receive(:notify).
          with(:project_success,
               resource.project.user,
               project: resource.project)

        resource.save!
      end
    end

    context 'when project is already successful' do
      let(:project) { create(:project, state: 'successful') }
      before        { resource.project = project }

      it 'does not send project_successful notification again' do
        expect(Notification).not_to receive(:notify_once)
        resource.save!
      end
    end

    context 'when is not confirmed yet' do
      before { resource.confirmed_at = nil }

      it 'notifies the contributor about confirmation' do
        Configuration.stub(:[]).with(:email_payments).and_return('finan@c.me')

        expect(Notification).to receive(:notify_once).
          with(:payment_confirmed,
               resource.user,
               { resource_id_name =>  resource.id },
               { resource_name    => resource,
                 project:         resource.project,
                 bcc:             'finan@c.me' })

        resource.save!
      end

      it 'updates confirmed_at' do
        resource.save!
        expect(resource.confirmed_at).not_to be_nil
      end
    end

    context 'when is already confirmed' do
      it 'does not send payment_confirmed notification again' do
        expect(Notification).not_to receive(:notify_once)
        resource
      end
    end

    context 'when project is already finished' do
      let(:user)          { create(:user, email: 'finan@c.me') }
      let(:default_state) { 'pending' }
      let(:confirmed_at)  { nil }

      before do
        Configuration.stub(:[]).and_return('finan@c.me')
        resource.project.stub(:expires_at).and_return(8.days.ago)
      end

      it 'notifies backoffice about confirmation' do
        allow(Notification).to receive(:notify_once)

        expect(Notification).to receive(:notify_once).at_least(:once).
          with(:payment_confirmed_after_finished_project,
               user,
               { resource_id_name => resource.id },
               resource_name      => resource)

        resource.confirm!
      end
    end
  end

  describe '#from_confirmed_to_canceled' do
    let(:user) { create(:user, email: 'finan@c.me') }
    before     { Configuration.stub(:[]).with(:email_payments).and_return('finan@c.me') }

    it 'notifies backoffice about cancelation' do
      expect(Notification).to receive(:notify_once).
        with(:payment_canceled_after_confirmed,
             user,
             { resource_id_name => resource.id },
             resource_name      => resource)

      resource.cancel!
    end
  end

  describe '#from_confirmed_to_requested_refund' do
    let(:user) { create(:user, email: 'finan@c.me') }
    before     { Configuration.stub(:[]).with(:email_payments).and_return('finan@c.me') }

    it 'notifies backoffice about the refund request' do
      resource.user.stub(:credits).and_return(1000)
      expect(Notification).to receive(:notify_once).
        with(:refund_request,
          user,
          { resource_id_name => resource.id },
          resource_name      => resource)

      resource.request_refund!
    end
  end
end
