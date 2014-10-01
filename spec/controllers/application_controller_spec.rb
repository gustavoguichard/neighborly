require 'spec_helper'

describe ApplicationController do
  describe '#referral_code' do
    it 'returns value stored in user\'s session' do
      session[:referral_code] = 'qwertyuiop'
      expect(subject.referral_code).to eql('qwertyuiop')
    end
  end
end
