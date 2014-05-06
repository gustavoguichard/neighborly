require 'spec_helper'

describe Shared::PaymentStateMachineHandler do
  shared_examples_for 'payment state machine' do
    let(:initial_state) { 'pending' }

    describe 'initial state' do
      let(:resource) { resource_class.new }

      it 'be pending' do
        expect(resource.pending?).to be_true
      end
    end

    describe '#pendent' do
      before { resource.pendent }

      context 'when in confirmed state' do
        let(:initial_state) { 'confirmed' }

        it 'changes to pending state' do
          expect(resource.pending?).to be_true
        end
      end
    end

    describe '#confirm' do
      before { resource.confirm }

      it 'changes to confirmed state' do
        expect(resource.confirmed?).to be_true
      end
    end

    describe '#push_to_trash' do
      before { resource.push_to_trash }

      it 'switch to deleted state' do
        expect(resource.deleted?).to be_true
      end
    end

    describe '#wait_confirmation' do
      before { resource.wait_confirmation }

      context 'when in peding state' do
        it 'changes to waiting_confirmation state' do
          expect(resource.waiting_confirmation?).to be_true
        end
      end

      context 'when in confirmed state' do
        let(:initial_state) { 'confirmed' }

        it 'doesn\'t changes to waiting_confirmation state' do
          expect(resource.waiting_confirmation?).to be_false
        end
      end
    end

    describe '#cancel' do
      before { resource.cancel }

      it 'changes to canceled state' do
        expect(resource.canceled?).to be_true
      end
    end

    describe '#request_refund' do
      let(:credits) { resource.value }
      let(:initial_state) { 'confirmed' }
      let(:resource_is_credits) { false }
      before do
        resource_observer_class.any_instance.stub(:notify_backoffice)
        resource.stub(:credits).and_return(resource_is_credits)
        resource.user.stub(:credits).and_return(credits)
        resource.request_refund
      end

      subject { resource.requested_refund? }

      context 'when resource is confirmed' do
        it 'changes to requested_refund state' do
          expect(subject).to be_true
        end
      end

      context 'when resource is credits' do
        let(:resource_is_credits) { true }

        it 'doesn\'t changes to requested_refund state' do
          expect(subject).to be_false
        end
      end

      context 'when resource is not confirmed' do
        let(:initial_state) { 'pending' }

        it 'doesn\'t changes to requested_refund state' do
          expect(subject).to be_false
        end
      end

      context 'when resource value is above user credits' do
        let(:credits) { resource.value - 1 }

        it 'doesn\'t changes to requested_refund state' do
          expect(subject).to be_false
        end
      end
    end

    describe '#refund' do
      before { resource.refund }

      context 'when resource is confirmed' do
        let(:initial_state) { 'confirmed' }

        it 'changes to refunded state' do
          expect(resource.refunded?).to be_true
        end
      end

      context 'when resource is requested refund' do
        let(:initial_state) { 'requested_refund' }

        it 'changes to refunded state' do
          expect(resource.refunded?).to be_true
        end
      end

      context 'when resource is pending' do
        it 'doesn\'t changes to refunded state' do
          expect(resource.refunded?).to be_false
        end
      end
    end
  end

  context 'when resource is Contribution' do
    let(:resource)                { create(:contribution, state: initial_state) }
    let(:resource_class)          { Contribution }
    let(:resource_observer_class) { ContributionObserver }
    it_should_behave_like 'payment state machine'
  end

  context 'when resource is Match' do
    let(:resource)                { create(:match, state: initial_state) }
    let(:resource_class)          { Match }
    let(:resource_observer_class) { ContributionObserver }
    it_should_behave_like 'payment state machine'
  end
end
