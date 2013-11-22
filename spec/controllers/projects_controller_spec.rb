#encoding:utf-8
require 'spec_helper'

describe ProjectsController do
  before{ Notification.unstub(:notify) }
  before{ Notification.unstub(:notify_once) }
  before{ controller.stub(:current_user).and_return(current_user) }
  before{ Configuration[:base_url] = 'http://catarse.me' }
  before{ Configuration[:email_projects] = 'foo@bar.com' }
  render_views
  subject{ response }
  let(:project){ create(:project, state: 'draft') }
  let(:current_user){ nil }

  describe "POST create" do
    let(:project){ build(:project) }
    before do
      post :create, { project: project.attributes }
    end

    context "when no user is logged in" do
      it{ should redirect_to new_user_session_path }
    end

    context "when user is logged in" do
      let(:current_user){ create(:user) }
      it{ should redirect_to success_project_path(project) }
    end
  end

  describe 'GET success' do
    let(:project){ create(:project) }

    context 'when has successful_created session' do
      before do
        session[:successful_created] = project.id
        get :success, id: project
      end

      it { expect(response).to be_success }

      it 'should set successful_created session as false' do
        expect(session[:successful_created]).to be_false
      end
    end

    context 'when does not have successful_created session' do
      before do
        session[:sucessful_created] = false
        get :success, id: project
      end

      it { expect(response).to redirect_to project_path(project) }
    end
  end

  describe 'GET index' do
    before do
      controller.stub(:last_tweets).and_return([])
      get :index
    end
    it { should be_success }

    describe 'staging env' do
      before do
        request.stub(:protocol).and_return("http://")
        request.stub(:host).and_return("staging.neighbor.ly")
        request.stub(:port).and_return(80)
        request.stub(:port_string).and_return(":80")
        request.stub(:path).and_return("/")
      end

      it 'should require basic auth' do
        get :index
        expect(response.status).to eq 401
      end
    end

    describe 'users without email' do
      let(:current_user) { create(:user) }

      before do
        current_user.update email: "change-your-email+#{current_user.id}@neighbor.ly"
        get :index
      end

      it { should redirect_to set_email_users_path }
    end
  end

  describe 'GET comments' do
    before do
      get :comments, id: project
    end
    it { should be_success }
  end

  describe 'GET budget' do
    before do
      get :budget, id: project
    end
    it { should be_success }
  end

  describe 'GET reports' do
    before do
      get :reports, id: project
    end

    context "when user is logged in" do
      let(:current_user){ project.user }
      it{ expect(response).to be_success }
    end

    context "when user is not logged in" do
      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  describe 'GET reward_contact' do
    context 'when request is not xhr' do
      before do
        get :reward_contact, id: project
      end
      it { should render_template layout: true }
      it { should be_success }
    end

    context 'when request is xhr' do
      before do
        xhr :get, :reward_contact, id: project
      end
      it { should render_template layout: false }
      it { should be_success }
    end
  end

  describe "GET send_to_analysis" do
    let(:current_user){ project.user }

    before do
      get :send_to_analysis, id: project.id, locale: :pt
      project.reload
    end

    it { project.in_analysis?.should be_true }
  end


  describe 'POST send_reward_email' do
    before do
      @send_reward_email_params = { id: project, name: 'some guy', email: 'some@emal.com', phone_number: '123456789', message: 'message' }
      ActionMailer::Base.deliveries.clear
    end

    context 'when simple captcha is valid' do
      before do
        controller.stub(:simple_captcha_valid?).and_return(true)
        post :send_reward_email, @send_reward_email_params
      end

      it { ActionMailer::Base.deliveries.should_not be_empty }
      it { expect(flash[:notice]).to eq 'We\'ve received your request and will be in touch shortly.' }
      it { should redirect_to(project_path(project)) }
    end

    context 'when simple captcha not is valid' do
      before do
        controller.stub(:simple_captcha_valid?).and_return(false)
        post :send_reward_email, @send_reward_email_params
      end

      it { ActionMailer::Base.deliveries.should be_empty }
      it { expect(flash[:error]).to eq 'The code is not valid. Try again.' }
      it { should redirect_to(project_path(project)) }
    end
  end

  describe 'GET near' do
    describe 'html format' do
      before { get :near, location: 'Kansas City, MO' }

      it { expect(response.status).to eq(404) }
    end

    describe 'xhr request' do
      before { xhr :get, :near, location: 'Kansas City, MO' }

      it { expect(response).to be_success }
    end
  end

  describe "GET index" do
    it { should be_success }

    context "with referal link" do
      subject { controller.session[:referal_link] }

      before do
        get :index, locale: :pt, ref: 'referal'
      end

      it { should == 'referal' }
    end
  end

  describe "GET new" do
    before { get :new }

    context "when user is a guest" do
      it { should_not be_success }
    end

    context "when user is a registered user" do
      let(:current_user){ create(:user, admin: false) }
      it { should be_success }
    end
  end

  describe "PUT update" do
    shared_examples_for "updatable project" do
      before { put :update, id: project, project: { name: 'My Updated Title' },locale: :pt }
      it {
        project.reload
        project.name.should == 'My Updated Title'
      }

      it{ should redirect_to project_path(project, anchor: 'edit') }
    end

    shared_examples_for "protected project" do
      before { put :update, id: project, project: { name: 'My Updated Title' },locale: :pt }
      it {
        project.reload
        project.name.should == 'Foo bar'
      }
    end

    context "when user is a guest" do
      it_should_behave_like "protected project"
    end

    context "when user is a project owner" do
      let(:current_user){ project.user }

      context "when project is offline" do
        it_should_behave_like "updatable project"
      end

      context "when project is online" do
        let(:project) { create(:project, state: 'online') }

        before do
          controller.stub(:current_user).and_return(project.user)
        end

        context "when I try to update the project name and the about field" do
          before{ put :update, id: project, project: { name: 'new_title', about: 'new_description' } }
          it "should not update neither" do
            project.reload
            project.name.should_not == 'new_title'
            project.about.should_not == 'new_description'
          end
        end

        context "when I try to update only the about field" do
          before{ put :update, id: project, project: { about: 'new_description' } }
          it "should update it" do
            project.reload
            project.about.should == 'new_description'
          end
        end
      end
    end

    context "when user is a registered user" do
      let(:current_user){ create(:user, admin: false) }
      it_should_behave_like "protected project"
    end

    context "when user is an admin" do
      let(:current_user){ create(:user, admin: true) }
      it_should_behave_like "updatable project"
    end
  end

  describe "GET embed" do
    before do
      get :embed, id: project
    end
    its(:status){ should == 200 }
  end

  describe "GET embed_panel" do
    before do
      get :embed_panel, id: project
    end
    its(:status){ should == 200 }
  end

  describe "GET show" do
    before do
      get :show, id: project
    end
    its(:status){ should == 200 }
  end

  describe "GET video" do
    context 'url is a valid video' do
      let(:video_url){ 'http://vimeo.com/17298435' }
      before do
        VideoInfo.stub(:get).and_return({video_id: 'abcd'})
        get :video, url: video_url
      end

      its(:body){ should == VideoInfo.get(video_url).to_json }
    end

    context 'url is not a valid video' do
      before { get :video, url: 'http://????' }

      its(:body){ should == nil.to_json }
    end
  end
end
