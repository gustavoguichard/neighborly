require 'spec_helper'

describe Organization do
  describe 'associations' do
    it { should belong_to :user }
  end
end
