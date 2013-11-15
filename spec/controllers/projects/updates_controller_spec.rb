require 'spec_helper'

describe Projects::UpdatesController do
  let(:update){ FactoryGirl.create(:update) }
  let(:current_user){ nil }
  before{ controller.stub(:current_user).and_return(current_user) }
  subject{ response }

  describe "GET index" do
    before{ get :index, project_id: update.project, locale: 'pt', format: 'html' }
    its(:status){ should == 200 }
  end

  describe "DELETE destroy" do
    before { delete :destroy, project_id: update.project, id: update.id, locale: 'pt' }
    context 'When user is a guest' do
      it { expect(response).to redirect_to(new_user_session_path) }
    end

    context "When user is a registered user but don't the project owner" do
      let(:current_user){ FactoryGirl.create(:user) }
      it { expect(response).to redirect_to(root_path) }
    end

    context 'When user is admin' do
      let(:current_user) { FactoryGirl.create(:user, admin: true) }
      it { expect(response).to redirect_to(project_updates_path(update.project)) }
    end

    context 'When user is project_owner' do
      let(:current_user) { update.project.user }
      it { expect(response).to redirect_to(project_updates_path(update.project)) }
    end
  end

  describe "POST create" do
    before{ post :create, project_id: update.project, locale: 'pt', update: {title: 'title', comment: 'update comment'} }
    context 'When user is a guest' do
      it{ Update.where(project_id: update.project).count.should == 1}
    end

    context "When user is a registered user but don't the project owner" do
      let(:current_user){ FactoryGirl.create(:user) }
      it{ Update.where(project_id: update.project).count.should == 1}
    end

    context 'When user is admin' do
      let(:current_user) { FactoryGirl.create(:user, admin: true) }
      it{ Update.where(project_id: update.project).count.should ==  2}
    end

    context 'When user is project_owner' do
      let(:current_user) { update.project.user }
      it{ Update.where(project_id: update.project).count.should ==  2}
    end
  end
end
