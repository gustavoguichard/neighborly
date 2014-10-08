require 'spec_helper'

describe Webhook::EventSender do
 let(:event) do
    Webhook::Event.create(serialized_record: { testing: true },
                          kind: 'user.created')
  end

  subject { described_class.new(event.id) }

  describe 'initialize' do
    it 'finds the event by given id' do
      expect(Webhook::Event).to receive(:find).with(event.id).and_call_original
      subject
    end
  end

  describe '#send_request' do
    it 'sends a post request' do
      expect(Net::HTTP).to receive(:post_form).and_call_original
      subject.send_request
    end

    it 'calls request_params' do
      expect_any_instance_of(Webhook::EventSender).to receive(:request_params).and_call_original
      subject.send_request
    end

    it 'calls webhook_url' do
      expect_any_instance_of(Webhook::EventSender).to receive(:webhook_url).and_call_original
      subject.send_request
    end
  end

  describe '#request_params' do
    it 'returns a hash with the record, type and authentication key' do
      allow_any_instance_of(Webhook::EventSender).to receive(:generate_authentication_key).
        and_return('1234')

      expect(subject.request_params).to eq({
        record: event.serialized_record.to_json,
        type: event.kind,
        authentication_key: '1234'
      })
    end
  end

  describe '#generate_authentication_key' do
    it 'generates a key using OpenSSL' do
      expect(OpenSSL::HMAC).to receive(:hexdigest).with(
        OpenSSL::Digest::SHA256.new,
        Configuration[:webhook_secret_key],
        event.serialized_record.to_s
      )
      subject.generate_authentication_key
    end

    it 'returns a key' do
      expect(subject.generate_authentication_key).not_to be_nil
    end
  end

  describe '#webhook_url' do
    it 'parses the url with URI' do
      expect(URI).to receive(:parse)
      subject.webhook_url
    end

    it 'gets webhook from configurations' do
      expect(Configuration).to receive(:[]).with(:neighborly_webhook_url).and_call_original
      subject.webhook_url
    end
  end
end
