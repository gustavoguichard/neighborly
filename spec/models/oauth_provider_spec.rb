require 'spec_helper'

describe OauthProvider do
  describe 'associations' do
    it { should have_many :authorizations }
  end
end
