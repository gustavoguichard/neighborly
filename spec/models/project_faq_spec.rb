require 'spec_helper'

describe ProjectFaq do
  describe "Validations" do
    it { should validate_presence_of(:answer) }
    it { should validate_presence_of(:project) }
    it { should validate_presence_of(:title) }
  end

  describe "Associations" do
    it { should belong_to(:project) }
  end
end
