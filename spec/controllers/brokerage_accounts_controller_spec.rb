require 'spec_helper'

describe BrokerageAccountsController do
  let(:params)         { { brokerage_account: attributes_for(:brokerage_account) } }
  let(:invalid_params) { { brokerage_account: {} } }

  context 'signed in' do
    before { sign_in current_user }
    let(:current_user) { create(:user) }

    describe 'GET new' do
      it 'assigns a new brokerage_account' do
        get :new
        expect(assigns(:brokerage_account)).to be_a_new(BrokerageAccount)
      end

      it 'initialize attributes of new resource using user data' do
        get :new
        expect(
          assigns(:brokerage_account).email
        ).to eql(current_user.email)
      end
    end

    describe 'POST create' do
      describe 'with valid params' do
        context 'with after_brokerage_url value stored' do
          before do
            session[:after_brokerage_url] = 'http://example.com/'
          end

          it 'creates user\'s brokerage account ' do
            post :create, params
            expect(current_user.reload.brokerage_account).to_not be_nil
          end

          it 'redirects to after_brokerage_url' do
            post :create, params
            expect(response).to redirect_to('http://example.com/')
          end
        end

        context 'without after_brokerage_path value stored' do
          it 'creates user\'s brokerage account ' do
            post :create, params
            expect(current_user.reload.brokerage_account).to_not be_nil
          end

          it 'redirects to root_path' do
            post :create, params
            expect(response).to redirect_to(root_path)
          end
        end
      end

      describe 'with invalid params' do
        it 'does not create a brokerage account' do
          expect {
            post :create, invalid_params
          }.to_not change(BrokerageAccount, :count)
        end

        it 'renders new view' do
          post :create, invalid_params
          expect(response).to render_template('new')
        end
      end
    end

    describe 'GET edit' do
      let(:current_user) { create(:user, :with_brokerage_account) }

      it 'renders new view' do
        get :edit
        expect(response).to render_template('new')
      end
    end

    describe 'PUT update' do
      let(:current_user) { create(:user, :with_brokerage_account) }

      describe 'with valid params' do
        context 'with after_brokerage_url value stored' do
          before do
            session[:after_brokerage_url] = 'http://example.com/'
          end
          let(:params) do
            p = super()
            p[:brokerage_account][:name] = 'New name'
            p
          end

          it 'changes user\'s brokerage account ' do
            allow(controller).to receive(:current_user).and_return(current_user)
            put :update, params
            expect(
              current_user.brokerage_account.reload.name
            ).to eql('New name')
          end

          it 'redirects to after_brokerage_url' do
            put :update, params
            expect(response).to redirect_to('http://example.com/')
          end
        end

        context 'without after_brokerage_path value stored' do
          it 'creates user\'s brokerage account ' do
            put :update, params
            expect(current_user.reload.brokerage_account).to_not be_nil
          end

          it 'redirects to root_path' do
            put :update, params
            expect(response).to redirect_to(root_path)
          end
        end
      end

      describe 'with invalid params' do
        before do
          allow_any_instance_of(BrokerageAccount).to receive(:update_attributes).and_return(false)
        end

        it 'does not create a brokerage account' do
          expect {
            put :update, params
          }.to_not change(BrokerageAccount, :count)
        end

        it 'renders new view' do
          put :update, params
          expect(response).to render_template('new')
        end
      end
    end
  end
end
