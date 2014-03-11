require 'spec_helper'

describe CompanyContact do
  describe 'validations' do
    it { should validate_presence_of :first_name }
    it { should validate_presence_of :last_name }
    it { should validate_presence_of :email }
    it { should validate_presence_of :company_name }
  end

  describe 'associations' do
    it { should have_many :notifications }
  end
end
