require 'spec_helper'

describe PayableDecorator do
  shared_examples_for 'payable' do
    let(:resource)     { build(resource_name, confirmed_at: confirmed_at, value: value) }
    let(:confirmed_at) { Time.now }
    let(:value)        { 10 }

    describe '#display_confirmed_at' do
      subject { resource.display_confirmed_at }

      context 'when confirmet_at is not nil' do
        let(:confirmed_at) { Time.now }

        it 'localizes the confirmed_at' do
          expect(subject).to eq I18n.l(resource.confirmed_at.to_date)
        end
      end

      context 'when confirmet_at is nil' do
        let(:confirmed_at) { nil }

        it 'returns nil' do
          expect(subject).to be_nil
        end
      end
    end

    describe '#display_value' do
      subject { resource.display_value }

      context 'when the value has decimal places' do
        let(:value) { 1199.99 }

        it 'formats the value with decimal places' do
          expect(subject).to eq '$1,199.99'
        end
      end

      context 'when the value does not have decimal places' do
        let(:value) { 1000 }

        it 'formats the value with 2 decimal places' do
          expect(subject).to eq '$1,000.00'
        end
      end
    end
  end

  context 'when its included on Contribution' do
    let(:resource_name) { :contribution }

    it_should_behave_like 'payable'
  end

  context 'when its included on Match' do
    let(:resource_name) { :match }

    it_should_behave_like 'payable'
  end
end

