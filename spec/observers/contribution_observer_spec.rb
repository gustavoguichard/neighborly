require 'spec_helper'

describe ContributionObserver do
  let(:resource) do
    create(:contribution,
           state:        resource_state,
           confirmed_at: confirmed_at,
           value:        1000)
  end
  let(:resource_class)   { Contribution }
  let(:resource_name)    { resource_class.model_name.param_key.to_sym }
  let(:resource_id_name) { "#{resource_name}_id".to_sym }
  let(:resource_state)   { 'confirmed' }
  let(:confirmed_at)     { Time.now }

  before do
    Notification.unstub(:notify)
    Notification.unstub(:notify_once)
  end

  describe '#after_create' do
    describe 'when updating status' do
      let(:resource_state) { 'pending' }

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

    context 'when project is already finished' do
      let(:user)           { create(:user, email: 'finan@c.me') }
      let(:resource_state) { 'pending' }
      let(:confirmed_at)   { nil }

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
end
