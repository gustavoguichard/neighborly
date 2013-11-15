require 'spec_helper'

describe Users::QuestionsController do
  let(:user) { create(:user) }
  let(:project) { create(:project) }

  shared_examples 'require login' do
    context "should redirect to login" do
      it { expect(response).to redirect_to(new_user_session_path) }
    end

    context 'should set a return to url' do
      it { expect(session[:return_to]).to eq(project_path(project, anchor: 'open-new-user-question-modal')) }
    end
  end

  context 'when user is not logged in' do
    describe "GET :new" do
      before { get :new, user_id: user.id, project_id: project.id }

      it_behaves_like 'require login'
    end

    describe "POST :create" do
      before { post :create, user_id: user.id, project_id: project.id }

      it_behaves_like 'require login'
    end
  end

  context 'when user is logged in' do
    before{ controller.stub(:current_user).and_return(current_user) }

    let(:current_user){ user }

    describe 'GET :new' do
      before { get :new, user_id: user.id, project_id: project.id }

      context 'should be success' do
        it { expect(response).to be_success }
      end

      context 'should not render the layout' do
        it { expect(response).to render_template(layout: false) }
      end
    end

    describe 'POST :create' do
      before { post :create, user_id: user.id, project_id: project.id, question: { body: 'test' } }

      context 'should be success' do
        it { expect(response).to redirect_to(project_path(project)) }
      end

      context 'shoul deliver the email' do
        it { ActionMailer::Base.deliveries.should have(1).item }
      end
    end
  end

end
