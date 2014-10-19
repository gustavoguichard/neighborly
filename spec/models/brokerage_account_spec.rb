require 'spec_helper'

describe BrokerageAccount do
  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    %i(address email name tax_id user).each do |attribute|
      it { should validate_presence_of(attribute) }
    end
  end
end
