require 'spec_helper'

describe Webhook::EventRegister do
  let(:record) { FactoryGirl.create(:user) }

  describe '#type' do
    it 'returns the model name with the event type as created' do
      expect(described_class.new(record, created: true).type).to eq 'user.created'
    end

    it 'returns the model name with the event type as updated' do
      expect(described_class.new(record).type).to eq 'user.updated'
    end
  end

  describe '.initialize' do
    it 'creates a Event record' do
      expect(Webhook::Event).to receive(:create).and_call_original
      described_class.new(record)
    end

    it 'calls the worker' do
      expect(Webhook::EventSenderWorker).to receive(:perform_async)
      described_class.new(record)
    end

    it 'serializes the record' do
      expect_any_instance_of(Webhook::EventRegister).to receive(:serialized_record).and_call_original
      described_class.new(record)
    end

    it 'calls the type method' do
      expect_any_instance_of(Webhook::EventRegister).to receive(:type).and_call_original
      described_class.new(record)
    end
  end

  describe '#serialized_record' do
    it 'uses EventRecordSerializer' do
      expect(Webhook::EventRecordSerializer).to receive(:new).with(record, root: false).and_call_original
      described_class.new(record)
    end
  end
end
