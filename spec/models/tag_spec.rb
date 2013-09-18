require 'spec_helper'

describe Tag do
  describe 'validations' do
    it { should validate_presence_of :name }
    it { should validate_uniqueness_of :name }
  end

  describe 'associations' do
    it { should have_many :taggings }
  end
end
