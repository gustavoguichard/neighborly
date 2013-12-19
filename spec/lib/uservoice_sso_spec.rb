require 'spec_helper'

describe Uservoice::Token do

  describe '.generate' do
    before do
      ::Configuration[:uservoice_subdomain] = 'foobar'
      ::Configuration[:uservoice_sso_key] = 'foobar_super_secret_key'
    end

    it { expect(Uservoice::Token.generate).to_not be_nil }
  end

end
