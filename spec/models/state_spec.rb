require 'spec_helper'

describe State do
  subject { create(:state) }

  describe "validations" do
    it{ should validate_presence_of(:name) }
    it{ should validate_uniqueness_of(:name).scoped_to(:acronym) }

    it{ should validate_presence_of(:acronym) }
    it{ should validate_uniqueness_of(:acronym).scoped_to(:name) }
  end
end
