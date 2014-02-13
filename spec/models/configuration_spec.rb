require 'spec_helper'

describe ::Configuration do
  before do
    @config = FactoryGirl.build(:configuration, name: 'a_config', value: 'a_value')
  end

  it { should validate_presence_of :name }

  it "should be valid from factory" do
    expect(@config).to be_valid
  end

  context "#get" do
    before do
      @config.save
      FactoryGirl.create(:configuration, name: 'other_config', value: 'another_value')
    end

    it "should get config" do
      expect(described_class[:a_config]).to eql('a_value')
    end

    it "should return nil when not found" do
      expect(described_class[:not_found_config]).to be_nil
    end

    it "should return array" do
      expect(
        described_class[:a_config, :other_config]
      ).to eql(['a_value', 'another_value'])
    end
  end

  describe "#fetch" do
    context "with existing key" do
      before { @config.save }

      it "should return the predefined value" do
        expect(described_class.fetch(:a_config)).to eql('a_value')
      end
    end

    context "with undefined key" do
      it "should raise exception" do
        expect {
          described_class.fetch(:not_found_config)
        }.to raise_error
      end
    end
  end
end
