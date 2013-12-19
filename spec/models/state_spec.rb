require 'spec_helper'

describe State do
  subject { create(:state) }

  describe "validations" do
    it{ should validate_presence_of(:name) }
    it{ should validate_uniqueness_of(:name).scoped_to(:acronym) }

    it{ should validate_presence_of(:acronym) }
    it{ should validate_uniqueness_of(:acronym).scoped_to(:name) }
  end

  describe '.array' do
    before do
      create(:state, name: 'California', acronym: 'CA')
      create(:state, name: 'Missouri', acronym: 'MO')
    end

    it { expect(State.array).to eq [['Select an option', ''], ['California - CA', 'CA'], ['Missouri - MO', 'MO']] }
  end
end
