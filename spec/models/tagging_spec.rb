require 'spec_helper'

describe Tagging do
  describe 'validations' do
    it { should validate_presence_of :tag }
    it { should validate_presence_of :project }
  end

  describe 'associations' do
    it { should belong_to :tag }
    it { should belong_to :project }
  end
end
