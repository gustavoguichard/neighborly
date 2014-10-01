require 'spec_helper'

describe RegistrationsController do
  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe '#create' do
    it 'relates users when referral_code parameter is given' do
      user_email = "sherlock.#{rand}@example.com"
      referrer   = create(:user)
      post :create, referral_code: referrer.referral_code, user: {
        email: user_email, password: '123123123'
      }
      expect(
        User.find_by(email: user_email).referrer
      ).to eql(referrer)
    end
  end
end
