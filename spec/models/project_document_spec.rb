require 'spec_helper'

describe ProjectDocument do
  describe "Validations" do
    it { validate_presence_of(:document) }
  end

  describe "Associations" do
    it { should belong_to(:project) }
  end
end
