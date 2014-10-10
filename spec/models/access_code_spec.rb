require 'spec_helper'

describe AccessCode do
  it { should validate_presence_of :code }
  it { should have_many :users }

  describe 'stil_valid?' do
    let(:access_code) { create(:access_code, max_users: 1) }

    it 'is valid' do
      expect(access_code.still_valid?).to be_true
    end

    it 'is not valid' do
      create(:user, access_code: access_code)
      expect(access_code.still_valid?).to be_false
    end
  end
end
