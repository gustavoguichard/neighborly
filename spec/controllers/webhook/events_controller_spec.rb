require 'spec_helper'

describe Webhook::EventsController do
  describe '#create' do
    it 'instantiates a new EventReceiver object' do
      allow_any_instance_of(Webhook::EventReceiver).to receive(:process_request)
      expect(Webhook::EventReceiver).to receive(:new).and_call_original
      post :create
    end

    it 'calls process_request' do
      expect_any_instance_of(Webhook::EventReceiver).to receive(:process_request)
      post :create
    end
  end
end
