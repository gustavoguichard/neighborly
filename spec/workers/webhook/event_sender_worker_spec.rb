require 'spec_helper'

describe Webhook::EventSenderWorker do
  let(:event) do
    Webhook::Event.create(serialized_record: { testing: true },
                          kind: 'user.created')
  end

  before do
    Sidekiq::Testing.inline!
  end

  let(:perform_async) { described_class.perform_async(event.id) }

  it 'satisfies expectations' do
    expect(Webhook::EventSender).to receive(:new).with(event.id).and_call_original
    expect_any_instance_of(Webhook::EventSender).to receive(:send_request)
    perform_async
  end
end

