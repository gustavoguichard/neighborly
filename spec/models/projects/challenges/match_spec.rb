require 'spec_helper'

describe Projects::Challenges::Match do
  it { should belong_to(:project) }
  it { should belong_to(:user) }

  describe 'validations' do
    it { should validate_numericality_of(:maximum_value).is_greater_than_or_equal_to(1_000) }
  end
end
