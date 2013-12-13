# coding: utf-8

require 'spec_helper'

describe Reward do
  let(:reward){ create(:reward, description: 'envie um email para foo@bar.com') }

  describe "Associations" do
    it{ should belong_to :project }
    it{ should have_many :backers }
  end

  it "should have a minimum value" do
    r = build(:reward, minimum_value: nil)
    r.should_not be_valid
  end

  it "should have a title" do
    r = build(:reward, title: nil)
    r.should_not be_valid
  end

  it "should have a greater than 10.00 minimum value" do
    r = build(:reward)
    r.minimum_value = -0.01
    r.should_not be_valid
    r.minimum_value = 9.99
    r.should_not be_valid
    r.minimum_value = 10.00
    r.should be_valid
    r.minimum_value = 10.01
    r.should be_valid
  end

  it "should have a description" do
    r = build(:reward, description: nil)
    r.should_not be_valid
  end

  it "should have integer maximum backers" do
    r = build(:reward)
    r.maximum_backers = 10.01
    r.should_not be_valid
    r.maximum_backers = 10
    r.should be_valid
  end

  it "should have maximum backers > 0" do
    r = build(:reward)
    r.maximum_backers = -1
    r.should_not be_valid
    r.maximum_backers = 0
    r.should_not be_valid
    r.maximum_backers = 1
    r.should be_valid
  end

  describe '.remaining' do
    subject { Reward.remaining }
    before do
      @remaining = create(:reward, maximum_backers: 3)
      create(:backer, state: 'confirmed', reward: @remaining, project: @remaining.project)
      create(:backer, state: 'waiting_confirmation', reward: @remaining, project: @remaining.project)
      @sold_out = create(:reward, maximum_backers: 2)
      create(:backer, state: 'confirmed', reward: @sold_out, project: @sold_out.project)
      create(:backer, state: 'waiting_confirmation', reward: @sold_out, project: @sold_out.project)
    end

    it{ should == [@remaining] }
  end

  describe '#sold_out?' do
    let(:reward) { create(:reward, maximum_backers: 3) }
    subject { reward.sold_out? }

    context 'when reward not have limits' do
      let(:reward) { create(:reward, maximum_backers: nil) }
      it { should be_false }
    end

    context 'when reward backers waiting confirmation and confirmed are greater than limit' do
      before do
        2.times { create(:backer, state: 'confirmed', reward: reward, project: reward.project) }
        create(:backer, state: 'waiting_confirmation', reward: reward, project: reward.project)
      end

      it { should be_true }
    end

    context 'when reward backers waiting confirmation and confirmed are lower than limit' do
      before do
        create(:backer, state: 'confirmed', reward: reward, project: reward.project)
        create(:backer, state: 'waiting_confirmation', reward: reward, project: reward.project)
      end
      it { should be_false }

    end
  end
end
