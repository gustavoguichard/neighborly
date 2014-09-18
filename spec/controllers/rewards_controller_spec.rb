require 'spec_helper'

describe RewardsController do
  subject{ response }
  let(:project) { FactoryGirl.create(:project) }
  let(:reward) { FactoryGirl.create(:reward, project: project) }

  shared_examples_for "GET rewards index" do
    before { get :index, project_id: project, locale: :pt }
    it { should be_success }
  end

  shared_examples_for "POST rewards create" do
    before { post :create, project_id: project, reward: { cusip_number: '840058TG6' }, locale: :pt }
    it { project.rewards.should_not be_empty}
  end

  shared_examples_for "POST rewards create without permission" do
    before { post :create, project_id: project, reward: { cusip_number: '840058TG6' }, locale: :pt }
    it { project.rewards.should be_empty}
  end

  shared_examples_for "PUT rewards update" do
    before { put :update, project_id: project, id: reward.id, reward: { cusip_number: '000000XXX' }, locale: :pt }
    it {
      reward.reload
      reward.cusip_number.should == '000000XXX'
    }
  end

  shared_examples_for "PUT rewards update without permission" do
    before { put :update, project_id: project, id: reward.id, reward: { cusip_number: '000000XXX' }, locale: :pt }
    it {
      reward.reload
      reward.cusip_number.should_not == '000000XXX'
    }
  end

  shared_examples_for "DELETE rewards destroy" do
    before { delete :destroy, project_id: project, id: reward.id, locale: :pt }
    it { project.rewards.should be_empty}
  end

  shared_examples_for "DELETE rewards destroy without permission" do
    before { delete :destroy, project_id: project, id: reward.id, locale: :pt }
    it { project.rewards.should_not be_empty}
  end

  context "When current_user is a guest" do
    before { controller.stub(:current_user).and_return(nil) }

    it_should_behave_like "GET rewards index"
    it_should_behave_like "POST rewards create without permission"
    it_should_behave_like "PUT rewards update without permission"
    it_should_behave_like "DELETE rewards destroy without permission"
  end

  context "When current_user is a project owner" do
    before { controller.stub(:current_user).and_return(project.user) }

    it_should_behave_like "GET rewards index"
    it_should_behave_like "POST rewards create"
    it_should_behave_like "PUT rewards update"
    it_should_behave_like "DELETE rewards destroy"
  end

  context "when current_user is admin" do
    before { controller.stub(:current_user).and_return(FactoryGirl.create(:user, admin: true))}

    it_should_behave_like "GET rewards index"
    it_should_behave_like "POST rewards create"
    it_should_behave_like "PUT rewards update"
    it_should_behave_like "DELETE rewards destroy"
  end

  context "When current_user is a registered user" do
    before { controller.stub(:current_user).and_return(FactoryGirl.create(:user)) }

    it_should_behave_like "GET rewards index"
    it_should_behave_like "POST rewards create without permission"
    it_should_behave_like "PUT rewards update without permission"
    it_should_behave_like "DELETE rewards destroy without permission"
  end
end
