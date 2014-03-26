require 'spec_helper'
require "cancan/matchers"

describe Ability do
  subject { Ability.new(user) }

  context "When user is admin" do
    let(:user) { FactoryGirl.create(:user, admin: true) }

    it { should be_able_to(:access, :all) }
  end

  describe 'when project has a channel' do
    let(:project) { FactoryGirl.create(:project, channels: [channel]) }
    let(:user) { create(:user, admin: false) }
    let(:channel) { create(:channel, user: user) }

    describe 'channel members' do
      let(:channel) { create(:channel, user: create(:user)) }
      let(:reward) { FactoryGirl.create(:reward, project: project) }
      before { channel.members << user; channel.save }

      it { should be_able_to(:destroy, reward) }
      it { should be_able_to(:update, reward, :days_to_delivery) }
      it { should be_able_to(:update, reward, :description) }
      it { should be_able_to(:update, reward, :title) }
      it { should be_able_to(:update, reward, :maximum_contributions) }
    end
  end

  context "When user is project owner" do
    let(:user) { FactoryGirl.create(:user) }
    let(:project) { FactoryGirl.create(:project, user: user) }
    let(:reward) { FactoryGirl.create(:reward, project: project) }

    it { should_not be_able_to(:access, :all) }
    it { should be_able_to(:update, reward)}

    describe "when project is approved" do
      before { project.approve }

      it { should be_able_to(:destroy, reward) }
      it { should be_able_to(:update, reward, :days_to_delivery) }
      it { should be_able_to(:update, reward, :description) }
      it { should be_able_to(:update, reward, :title) }
      it { should be_able_to(:update, reward, :maximum_contributions) }

      context "and someone make a back and select a reward" do
        context "when contribution is in time to confirm and not have confirmed contributions" do
          before { FactoryGirl.create(:contribution, project: project, state: 'waiting_confirmation', reward: reward) }

          it { should_not be_able_to(:update, reward, :minimum_value) }
          it { should_not be_able_to(:destroy, reward) }
          it { should be_able_to(:update, reward, :description) }
          it { should be_able_to(:update, reward, :maximum_contributions) }
          it { should be_able_to(:update, reward, :days_to_delivery) }
        end

        context "when contribution is not in time to confirm and have confirmed contributions" do
          before { FactoryGirl.create(:contribution, project: project, reward: reward, created_at: 7.day.ago, state: 'confirmed') }

          it { should_not be_able_to(:update, reward, :minimum_value) }
          it { should_not be_able_to(:destroy, reward) }
          it { should be_able_to(:update, reward, :description) }
          it { should be_able_to(:update, reward, :maximum_contributions) }
          it { should be_able_to(:update, reward, :days_to_delivery) }
        end

        context "when contribution is not in time to confirm and not have confirmed contributions" do
          before { FactoryGirl.create(:contribution, project: project, reward: reward, payment_token: 'ABC', created_at: 7.day.ago, state: 'pending') }

          it { should be_able_to(:update, reward, :minimum_value) }
          it { should be_able_to(:destroy, reward) }
          it { should be_able_to(:update, reward, :description) }
          it { should be_able_to(:update, reward, :maximum_contributions) }
          it { should be_able_to(:update, reward, :days_to_delivery) }
        end
      end
    end
  end

  context "When is regular user" do
    let(:user) { FactoryGirl.create(:user) }
    let(:project) { FactoryGirl.create(:project) }
    let(:reward) { FactoryGirl.create(:reward, project: project) }
    let(:authorization) { FactoryGirl.create(:authorization, user: user) }

    it { should_not be_able_to(:access, :all) }
    it { should_not be_able_to(:update, reward)}
    it { should be_able_to(:destroy, authorization)}
  end

  context "When is a guest" do
    let(:user) { nil }
    let(:project) { FactoryGirl.create(:project) }
    let(:reward) { FactoryGirl.create(:reward, project: project) }

    it { should_not be_able_to(:access, :all) }
    it { should_not be_able_to(:update, reward)}
  end
end
