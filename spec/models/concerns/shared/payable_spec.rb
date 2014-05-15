require 'spec_helper'

describe Shared::Payable do
  shared_examples_for 'payable' do
    subject { resource }

    it { should have_many :payment_notifications }

    describe '#price_in_cents' do
      it 'returns the resource value in cents' do
        expect(subject.price_in_cents).to eq 100000
      end
    end

    describe '#define_key!' do
      before { Kernel.stub(:rand).and_return(1) }

      it 'updates the resource key' do
        resource.define_key!

        expect(resource.key).to eq(
          Digest::MD5.new.update("#{resource.id}###{resource.created_at}##1").to_s)
      end
    end
  end

  context 'when its included on Contribution' do
    let(:resource) { create(:contribution, value: 1000, key: 'something') }

    it_should_behave_like 'payable'
  end

  context 'when its included on Match' do
    let(:resource) { create(:match, value: 1000, key: 'something') }

    it_should_behave_like 'payable'
  end
end
