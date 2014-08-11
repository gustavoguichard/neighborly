require 'spec_helper'

describe PaymentObserver do
  shared_examples_for 'payment observer' do
    let(:resource_name)    { resource_class.model_name.param_key.to_sym }
    let(:resource_id_name) { "#{resource_name}_id".to_sym }
    let(:confirmed_at)     { Time.now }

    describe '#after_create' do
      it 'calls #define_key!' do
        expect_any_instance_of(resource_class).to receive(:define_key!)
        create(resource_name)
      end
    end

    describe '#before_save' do
      context 'when is not resource confirmed yet' do
        before { resource.confirmed_at = nil }

        it 'notifies the contributor about confirmation' do
          expect(Notification).to receive(:notify_once).
            with(:payment_confirmed,
                 resource.user,
                 { resource_id_name =>  resource.id },
                 { resource_name    => resource,
                   project:         resource.project,
                   bcc:             ENV['EMAIL_PAYMENTS'] })

          resource.save!
        end

        it 'updates confirmed_at' do
          resource.save!
          expect(resource.confirmed_at).not_to be_nil
        end
      end

      context 'when resource is already confirmed' do
        it 'does not send payment_confirmed notification again' do
          expect(Notification).not_to receive(:notify_once)
          resource
        end
      end
    end

    describe '#from_confirmed_to_canceled' do
      let(:user) { create(:user, email: ENV['EMAIL_PAYMENTS'].dup) }

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
      let(:user) { create(:user, email: ENV['EMAIL_PAYMENTS'].dup) }

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

  context 'when resource is a Contribution' do
    let(:resource_class) { Contribution }
    let(:resource) do
      create(:contribution,
             state: 'confirmed',
             confirmed_at: confirmed_at,
             value: 1000)
    end

    it_should_behave_like 'payment observer'
  end

  context 'when resource is a Match' do
    let(:resource_class) { Match }
    let(:resource) do
      create(:match,
             state: 'confirmed',
             confirmed_at: confirmed_at,
             value: 1000)
    end

    it_should_behave_like 'payment observer'
  end
end
