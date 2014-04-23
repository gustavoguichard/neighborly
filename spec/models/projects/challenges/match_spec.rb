require 'spec_helper'

describe Projects::Challenges::Match do
  it { should belong_to(:project) }
  it { should belong_to(:user) }
end
