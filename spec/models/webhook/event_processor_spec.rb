require 'spec_helper'

describe Webhook::EventProcessor do
  let(:user)           { FactoryGirl.create(:user) }
  let(:record_source)  { user }
  let(:event)          { Webhook::EventRegister.new(record_source).event }
  subject              { described_class.new(params[:record]) }
  let(:params)         { Webhook::EventReceiver.new(request_params).params }

  let!(:request_params) do
    Webhook::EventSender.new(event.id).request_params
  end

  shared_examples_for 'create' do
    before { record_source.destroy }

    it 'disables observers' do
      expect(model_class.observers).to receive(:disable).and_call_original
      subject.send(method_name)
    end

    it 'instantiates a new object' do
      expect(model_class).to receive(:new).with(params[:record]).and_call_original
      subject.send(method_name)
    end

    it 'saves without validations' do
      expect_any_instance_of(model_class).to receive(:save).with(validate: false).and_call_original
      subject.send(method_name)
    end

    it 'uses strong parameters' do
      expect_any_instance_of(ActionController::Parameters).to receive(:permit).and_call_original
      expect(model_class).to receive(:attribute_names).and_call_original
      subject.send(method_name)
    end
  end

  shared_examples_for 'update' do
    it 'finds the record by id' do
      expect(model_class).to receive(:find).with(params[:record][:id])
      subject.send(method_name)
    end

    it 'updates the columns' do
      expect_any_instance_of(model_class).to receive(:update_columns)
      subject.send(method_name)
    end

    it 'uses strong parameters' do
      expect_any_instance_of(ActionController::Parameters).to receive(:permit).and_call_original
      expect(model_class).to receive(:attribute_names).and_call_original
      subject.send(method_name)
    end
  end

  describe '#authorization_created' do
    let(:record_source) { FactoryGirl.create(:authorization) }
    let(:method_name)   { 'authorization_created' }
    let(:model_class)   { Authorization }

    it_behaves_like 'create'
  end

  describe '#contributor_created' do
    let(:record_source) { Neighborly::Balanced::Contributor.create!(user: user) }
    let(:method_name)   { 'contributor_created' }
    let(:model_class)   { Neighborly::Balanced::Contributor }

    it_behaves_like 'create'
  end

  describe '#organization_created' do
    let(:record_source) { FactoryGirl.create(:organization) }
    let(:method_name)   { 'organization_created' }
    let(:model_class)   { Organization }

    it_behaves_like 'create'
  end

  describe '#user_created' do
    let(:method_name) { 'user_created' }
    let(:model_class) { User }

    it_behaves_like 'create'
  end

  describe '#contributor_updated' do
    let(:record_source) { Neighborly::Balanced::Contributor.create!(user: user) }
    let(:method_name)   { 'contributor_updated' }
    let(:model_class)   { Neighborly::Balanced::Contributor }

    it_behaves_like 'update'
  end

  describe '#organization_updated' do
    let(:record_source) { FactoryGirl.create(:organization) }
    let(:method_name)   { 'organization_updated' }
    let(:model_class)   { Organization }

    it_behaves_like 'update'
  end

  describe '#authorization_updated' do
    let(:record_source) { FactoryGirl.create(:authorization) }
    let(:method_name)   { 'authorization_updated' }
    let(:model_class)   { Authorization }

    it_behaves_like 'update'
  end

  describe '#user_updated' do
    let(:method_name) { 'user_updated' }
    let(:model_class) { User }

    it_behaves_like 'update'
  end
end

