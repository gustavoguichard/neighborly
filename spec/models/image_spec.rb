require 'spec_helper'

describe Image do
  describe 'validations' do
    it { should validate_presence_of :file }
  end

  describe 'associations' do
    it { should belong_to :user }
  end
end
