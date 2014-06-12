require 'spec_helper'

describe Concerns::AuthenticationHandler do
  let(:controller) { ApplicationController.new }

  describe '#base_domain_with_https_url_params' do
    subject { controller.base_domain_with_https_url_params }
    context 'when rails env is production and IS_STAGING is not setted' do
      before do
        Rails.env.stub(:production?).and_return(true)
        ENV['IS_STAGING'] = nil
      end

      it 'returns a hash with protocol and host' do
        expect(subject).to eq({
          protocol: 'https',
          host: 'localhost'
        })
      end
    end

    context 'when the env is production and IS_STAGING is setted' do
      before do
        Rails.env.stub(:production?).and_return(true)
        ENV['IS_STAGING'] = 'true'
      end

      it 'returns a empty hash' do
        expect(subject).to eq({})
      end
    end

    context 'when the env is not production and IS_STAGING is setted' do
      before do
        Rails.env.stub(:production?).and_return(false)
        ENV['IS_STAGING'] = 'true'
      end

      it 'returns a empty hash' do
        expect(subject).to eq({})
      end
    end
  end
end
