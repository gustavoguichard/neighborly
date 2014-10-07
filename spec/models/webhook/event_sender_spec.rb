require 'spec_helper'

describe Webhook::EventSender do
 let(:event) do
    Webhook::Event.create(serialized_record: { testing: true },
                          kind: 'created')
  end

  describe 'initialize' do
    it 'finds the event by given id' do
      expect(Webhook::Event).to receive(:find).with(event.id).and_call_original
      described_class.new(event.id)
    end
  end


end
