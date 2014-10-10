require 'spec_helper'

describe Webhook::EventReceiver do
  let(:user)           { FactoryGirl.create(:user) }
  let(:record_source)  { user }
  let(:event)          { Webhook::EventRegister.new(record_source).event }
  subject              { described_class.new(request_params) }
  let(:params)         { subject.params }

  let!(:request_params) do
    Webhook::EventSender.new(event.id).request_params
  end

  describe '#process_request' do
    it 'raises error when request is invalid' do
      params[:record].merge!({ a: 1 })
      expect{ subject.process_request }.to raise_error
    end

    it 'call method to deal with the changes' do
      expect(Webhook::EventProcessor).to receive(:new).with(params[:record]).and_call_original
      expect_any_instance_of(Webhook::EventProcessor).to receive(:user_updated)
      subject.process_request
    end

    it 'does not call method to deal with the change when type is invalid' do
      params.merge!({ type: 'project.created' })
      expect(Webhook::EventProcessor).not_to receive(:new)
      subject.process_request
    end
  end

  describe '#valid_request?' do
    it 'returns true when the request is valid' do
      expect(subject.valid_request?).to be_true
    end

    it 'returns false when request is invalid' do
      params[:record].merge!({ a: 1 })
      expect(subject.valid_request?).to be_false
    end
  end
end
