require 'spec_helper'

describe Tag do
  describe 'validations' do
    it { should validate_presence_of :name }
    it { should validate_uniqueness_of :name }
  end

  describe 'associations' do
    it { should have_many :taggings }
  end

  describe 'should save the name lowercase' do
    let(:tag) { Tag.create name: 'Test' }
    it { expect(tag.name).to eq 'test' }
  end
end
