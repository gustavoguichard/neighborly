require 'spec_helper'

describe OmniauthCallbacksController do
  let(:oauth_data) { OmniAuth.config.mock_auth[:default] }

  before do
    request.env['devise.mapping'] = Devise.mappings[:user]
    request.env['omniauth.auth']  = oauth_data
  end

  context 'on callback to existing Oauth Provider' do
    let(:authorization) do
      FactoryGirl.create(:authorization,
        uid:            oauth_data[:uid],
        oauth_provider: provider
      )
    end
    let(:user) { FactoryGirl.create(:user, authorizations: [authorization]) }
    let(:provider) { FactoryGirl.create(:oauth_provider, name: :facebook) }
    let(:serialized_user) { { email: 'juquinha@neighbor.ly' } }
    before do
      controller.stub(:current_user).and_return(user)
    end

    describe 'GET \'facebook\'' do
      it 'completes an omniauth signin with serialized omniauth user' do
        OmniauthUserSerializer.any_instance.stub(:to_h).and_return(serialized_user)
        session[:new_user_attrs] = { email: 'foobar@example.com' }
        expect_any_instance_of(OmniauthSignIn).to receive(:complete).
          with(serialized_user, session[:new_user_attrs])
        get :facebook
      end

      describe 'response' do
        context 'on OmniauthSignIn with status :success' do
          before do
            OmniauthSignIn.any_instance.stub(:status).and_return(:success)
          end

          it 'sign in user' do
            expect(controller).to receive(:sign_in)
            get :facebook
          end

          it 'redirects to default path of Devise\'s logins' do
            path = 'http://example.com/foobar'
            controller.stub(:after_sign_in_path_for).and_return(path)
            get :facebook
            expect(response).to redirect_to(path)
          end
        end

        context 'on OmniauthSignIn with status :needs_ownership_confirmation' do
          before do
            OmniauthSignIn.any_instance.stub(:status).and_return(:needs_ownership_confirmation)
          end

          it 'stores omniauth sign in data in session' do
            OmniauthSignIn.any_instance.stub(:data).and_return(serialized_user)
            get :facebook
            expect(session[:new_user_attrs]).to eql(serialized_user)
          end

          it 'redirects to new session path' do
            get :facebook
            expect(response).to redirect_to(new_user_session_path)
          end
        end

        context 'on OmniauthSignIn with status :needs_email' do
          before do
            OmniauthSignIn.any_instance.stub(:status).and_return(:needs_email)
          end

          it 'stores omniauth sign in data in session' do
            OmniauthSignIn.any_instance.stub(:data).and_return(serialized_user)
            get :facebook
            expect(session[:new_user_attrs]).to eql(serialized_user)
          end

          it 'redirects to set new user email path' do
            get :facebook
            expect(response).to redirect_to(set_new_user_email_path)
          end
        end
      end
    end
  end

  context 'on callback to non existing Oauth Provider' do
    it 'responds with error on url generation' do
      expect {
        get :my_new_provider
      }.to raise_error(ActionController::UrlGenerationError)
    end
  end
end
