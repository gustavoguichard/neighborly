require 'spec_helper'

describe ::Configuration do
  before { ENV.stub(:[]).with('SOME_CONFIG').and_return('some_value') }

  context '.get' do
    context 'with existing key' do
      it 'gets the config' do
        expect(described_class[:some_config]).to eql('some_value')
      end
    end

    context 'with undefined key' do
      before { ENV.stub(:[]).with('NOT_FOUND_CONFIG').and_return(nil) }

      it 'returns nil' do
        expect(described_class[:not_found_config]).to be_nil
      end
    end
  end

  context '.set' do
    it 'sets the config' do
      expect(ENV).to receive(:[]=).with('NOT_FOUND_CONFIG', 'the_new_value')
      described_class[:not_found_config] = 'the_new_value'
    end
  end

  describe '.fetch' do
    context 'with existing key' do
      it 'returns the predefined value' do
        expect(described_class.fetch(:some_config)).to eql('some_value')
      end
    end

    context 'with undefined key' do
      before { ENV.stub(:[]).with('NOT_FOUND_CONFIG').and_return(nil) }

      it 'raises exception' do
        expect {
          described_class.fetch(:not_found_config)
        }.to raise_error
      end
    end
  end
end
