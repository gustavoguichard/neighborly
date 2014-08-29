require 'spec_helper'

describe ContributionForm do
  it 'accepts values just greater than or equal to 10' do
    expect(subject).to validate_numericality_of(:value).
      is_greater_than_or_equal_to(10)
  end
end
