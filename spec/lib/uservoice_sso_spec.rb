require 'spec_helper'

describe Uservoice::Token do

  describe '.generate' do
    it { expect(Uservoice::Token.generate).to_not be_nil }
  end

end
