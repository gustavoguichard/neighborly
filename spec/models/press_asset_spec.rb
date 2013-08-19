require 'spec_helper'

describe PressAsset do
  describe 'validations' do
    it { should validate_presence_of :title }
    it { should validate_presence_of :url }
    it { should validate_presence_of :image }
  end
end
