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
  end

  context 'when resource is Contribution' do
    let(:initial_state)           { 'deleted' }
    let(:resource)                { create(:contribution, state: initial_state) }
    let(:resource_class)          { Contribution }
    let(:resource_observer_class) { ContributionObserver }
    it_should_behave_like 'payment state machine'

    describe 'after state transitions' do
      it 'updates a MatchedContributionGenerator instance' do
        resource.state_transitions.map(&:event).each do |event|
          generator = double('MatchedContributionGenerator')
          MatchedContributionGenerator.stub(:new).and_return(generator)
          expect(generator).to receive(:update)

          resource.public_send(event)
        end
      end
    end
  end

  context 'when resource is Match' do
    let(:resource)                { create(:match, state: initial_state) }
    let(:resource_class)          { Match }
    let(:resource_observer_class) { ContributionObserver }
    it_should_behave_like 'payment state machine'
  end
end
