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
      expect(subject).to receive(:user_updated).with(params[:record])
      subject.process_request
    end

    it 'does not call method to deal with the change when type is invalid' do
      params.merge!({ type: 'project.created' })
      expect(subject).not_to receive(:send)
      subject.process_request
    end
  end

  describe '#user_updated' do
    it 'finds a user by id' do
      expect(User).to receive(:find).with(params[:record][:id])
      subject.send(:user_updated, params[:record])
    end

    it 'updates the columns' do
      expect_any_instance_of(User).to receive(:update_columns)
      subject.send(:user_updated, params[:record])
    end
  end

  describe '#user_created' do
    before { record_source.destroy }

    it 'disables user observers' do
      expect(User.observers).to receive(:disable).and_call_original
      subject.send(:user_created, params[:record])
    end

    it 'instantiates a new user object' do
      expect(User).to receive(:new).with(params[:record]).and_call_original
      subject.send(:user_created, params[:record])
    end

    it 'saves without validations' do
      expect_any_instance_of(User).to receive(:save).with(validate: false).and_call_original
      subject.send(:user_created, params[:record])
    end
  end

  describe '#contributor_updated' do
    let(:record_source) { Neighborly::Balanced::Contributor.create!(user: user) }

    it 'finds a contributor by id' do
      expect(Neighborly::Balanced::Contributor).to receive(:find).with(params[:record][:id])
      subject.send(:contributor_updated, params[:record])
    end

    it 'updates the columns' do
      expect_any_instance_of(Neighborly::Balanced::Contributor).to receive(:update_columns)
      subject.send(:contributor_updated, params[:record])
    end
  end

  describe '#contributor_created' do
    let(:record_source) { Neighborly::Balanced::Contributor.create!(user: user) }
    before { record_source.destroy }

    it 'disables contributor observers' do
      expect(Neighborly::Balanced::Contributor.observers).to receive(:disable).and_call_original
      subject.send(:contributor_created, params[:record])
    end

    it 'instantiates a new contributor object' do
      expect(Neighborly::Balanced::Contributor).to receive(:new).with(params[:record]).and_call_original
      subject.send(:contributor_created, params[:record])
    end

    it 'saves without validations' do
      expect_any_instance_of(Neighborly::Balanced::Contributor).to receive(:save).with(validate: false).and_call_original
      subject.send(:contributor_created, params[:record])
    end
  end

  describe '#valid_request?' do
    it 'returns true when the request is valid' do
      expect(subject.send(:valid_request?)).to be_true
    end

    it 'returns false when request is invalid' do
      params[:record].merge!({ a: 1 })
      expect(subject.send(:valid_request?)).to be_false
    end
  end
end
