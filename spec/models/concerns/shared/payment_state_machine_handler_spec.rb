require 'spec_helper'

describe Shared::PaymentStateMachineHandler do
  let(:initial_state) { 'pending' }

  shared_examples_for 'payment state machine' do
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
      let(:initial_state) { 'pending' }
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

    describe '#refund' do
      before { resource.refund }

      context 'when resource is confirmed' do
        let(:initial_state) { 'confirmed' }

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

    describe '#wait_broker' do
      before { resource.wait_broker }

      context 'when resource is pending' do
        let(:initial_state) { 'pending' }

        it 'changes to waiting_broker state' do
          expect(resource.waiting_broker?).to be_true
        end
      end

      context 'when resource is not pending' do
        let(:initial_state) { 'canceled' }

        it 'doesn\'t changes to refunded state' do
          expect(resource.waiting_broker?).to be_false
        end
      end
    end
  end

  context 'when resource is Contribution' do
    let(:initial_state)           { 'deleted' }
    let(:resource)                { create(:contribution, state: initial_state) }
    let(:resource_class)          { Contribution }
    let(:resource_observer_class) { ContributionObserver }
    it_should_behave_like 'payment state machine'
  end
end
