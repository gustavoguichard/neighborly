#encoding:utf-8
require 'spec_helper'

describe UsersController do
  render_views
  subject{ response }
  before do
    controller.stub(:current_user).and_return(current_user)
  end

  let(:successful_project){ FactoryGirl.create(:project, state: 'successful') }
  let(:failed_project){ FactoryGirl.create(:project, state: 'failed') }
  let(:contribution){ FactoryGirl.create(:contribution, state: 'confirmed', user: user, project: failed_project) }
  let(:user){ FactoryGirl.create(:user, password: 'current_password', password_confirmation: 'current_password', authorizations: [FactoryGirl.create(:authorization, uid: 666, oauth_provider: FactoryGirl.create(:oauth_provider, name: 'facebook'))]) }
  let(:current_user){ user }

  describe "PUT update" do
    context 'when does not update the email' do
      before do
        put :update, id: user.id, locale: 'pt', user: { twitter_url: 'http://twitter.com/test' }
      end
      it("should update the user") do
        user.reload
        user.twitter_url.should ==  'http://twitter.com/test'
      end
      it{ should redirect_to edit_user_path(user) }
      it { expect(flash.notice).to eq(I18n.t('controllers.users.update.success')) }
    end

    context 'when does update the email' do
      before do
        put :update, id: user.id, locale: 'pt', user: { email: 'test-foobar@barfoo.com' }
      end
      it { expect(flash.notice).to eq(I18n.t('devise.confirmations.send_instructions')) }
      it{ should redirect_to edit_user_path(user) }
    end

    context 'as JSON format' do
      context 'success' do
        before do
          put :update, id: user.id, locale: 'pt', user: { twitter_url: 'http://twitter.com/test' }, format: :json
        end

        its(:status){ should == 200 }
      end

      context 'failure' do
        before do
          put :update, id: user.id, locale: 'pt', user: { email: '' }, format: :json
        end

        its(:body) { should == { status: :error }.to_json }
        its(:status){ should == 200 }
      end
    end
  end

  describe "PUT update_password" do
    let(:current_password){ 'current_password' }
    let(:password){ 'newpassword123' }
    let(:password_confirmation){ 'newpassword123' }
    before do
      put :update_password, id: user.id, locale: 'pt', user: { current_password: current_password, password: password, password_confirmation: password_confirmation }
    end

    context "with wrong current password" do
      let(:current_password){ 'wrong_password' }
      it{ flash.alert.should_not be_empty }
      it{ should redirect_to settings_user_path(user) }
    end

    context "with right current password and right confirmation" do
      it{ flash.notice.should_not be_empty }
      it{ flash.alert.should      be_nil }
      it{ should redirect_to settings_user_path(user) }
    end
  end

  describe "PUT update_email" do
    let(:email){ 'new_email@bar.com' }
    let(:return_to){ nil }
    before do
      session[:return_to] = return_to
      put :update_email, id: user.id, locale: 'pt', user: {email: email}
    end

    context "when email is not valid" do
      let(:email){ 'new_email_bar.com' }
      it{ should render_template('set_email') }
    end

    context "when email is valid" do
      context 'when account is not confirmed' do
        it("should not update the user") do
          user.reload
          user.email.should == user.email
        end
        it{ should redirect_to root_path(user) }
      end

      context 'when account is confirmed' do
        it("should update the user") do
          user.reload.confirm!
          user.email.should == 'new_email@bar.com'
        end
        it{ should redirect_to root_path(user) }
      end
    end
  end

  describe "GET show" do
    context 'as a person/organization' do
      before do
        get :show, id: user.id, locale: 'pt'
      end

      it{ assigns(:fb_admins).should include(user.facebook_id.to_i) }
    end

    context 'as a channel' do
      let(:channel) { create(:channel) }
      before do
        get :show, id: channel.user.id
      end
      it { should redirect_to(root_url(subdomain: channel.permalink)) }
    end
  end

  describe "GET edit" do
    context "when I'm not logged in" do
      let(:current_user){ nil }
      before do
        get :edit, id: user
      end
      it{ should redirect_to new_user_session_path }
    end

    context "when I'm loggedn" do

      context 'as normal request' do
        before { get :edit, id: user }

        its(:status){ should == 200 }

        it 'should assigns the correct resource' do
          expect(assigns(:user)).to eq user
        end

        it { should render_template(:edit) }
      end

      context 'as xhr request' do
        before { xhr :get, :edit, id: user }

        its(:status){ should == 200 }

        it 'should assigns the correct resource' do
          expect(assigns(:user)).to eq user
        end

        it { should render_template(:profile) }
      end
    end
  end

  describe "GET credits" do
    context "when I'm not logged in" do
      let(:current_user){ nil }
      before do
        get :credits, id: user
      end
      it{ should redirect_to new_user_session_path }
    end

    context "when I'm loggedn" do

      context 'as normal request' do
        before { get :credits, id: user }

        its(:status){ should == 200 }

        it 'should assigns the correct resource' do
          expect(assigns(:user)).to eq user
        end

        it { should render_template(:edit) }
      end

      context 'as xhr request' do
        before { xhr :get, :credits, id: user }

        its(:status){ should == 200 }

        it 'should assigns the correct resource' do
          expect(assigns(:user)).to eq user
        end

        it { should render_template(:credits) }
      end
    end
  end

  describe "GET settings" do
    context "when I'm not logged in" do
      let(:current_user){ nil }
      before do
        get :settings, id: user
      end
      it{ should redirect_to new_user_session_path }
    end

    context "when I'm loggedn" do

      context 'as normal request' do
        before { get :settings, id: user }

        its(:status){ should == 200 }

        it 'should assigns the correct resource' do
          expect(assigns(:user)).to eq user
        end

        it { should render_template(:edit) }
      end

      context 'as xhr request' do
        before { xhr :get, :settings, id: user }

        its(:status){ should == 200 }

        it 'should assigns the correct resource' do
          expect(assigns(:user)).to eq user
        end

        it { should render_template(:settings) }
      end
    end
  end

  describe "GET payments" do
    context "when I'm not logged in" do
      let(:current_user){ nil }
      before do
        get :payments, id: user
      end
      it{ should redirect_to new_user_session_path }
    end

    context "when I'm loggedn" do

      context 'as normal request' do
        before { get :payments, id: user }

        its(:status){ should == 200 }

        it 'should assigns the correct resource' do
          expect(assigns(:user)).to eq user
        end

        it { should render_template(:edit) }
      end

      context 'as xhr request' do
        before { xhr :get, :payments, id: user }

        its(:status){ should == 200 }

        it 'should assigns the correct resource' do
          expect(assigns(:user)).to eq user
        end

        it { should render_template(:payments) }
      end
    end
  end

  describe "GET set_email" do
    context "when I'm not logged in" do
      let(:current_user){ nil }
      before do
        get :set_email
      end
      it{ should redirect_to new_user_session_path }
    end

    context "when I'm loggedn" do
      before { get :set_email }

      its(:status){ should == 200 }

      it 'should assigns the correct resource' do
        expect(assigns(:user)).to eq user
      end

      it { should render_template(:set_email) }
    end
  end
end
