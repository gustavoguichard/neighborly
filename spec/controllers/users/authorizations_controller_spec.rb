require 'spec_helper'

describe Users::AuthorizationsController do
  let(:user) { authorization.user }
  let(:authorization) { create(:authorization) }

  context 'Not authenticated' do
    it 'redirects to new login page' do
      delete :destroy, id: authorization.id, user_id: user
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'does not delete the user' do
      delete :destroy, id: authorization.id, user_id: user
      expect {
        authorization.reload
      }.not_to raise_error
    end
  end

  context 'Authenticated' do
    before do
      controller.stub(:current_user).and_return(user)
    end

    it 'redirects to edit user page' do
      delete :destroy, id: authorization.id, user_id: user
      expect(response).to redirect_to(edit_user_path(user))
    end

    it 'deletes the authorization' do
      delete :destroy, id: authorization.id, user_id: user
      expect {
        authorization.reload
      }.to raise_error
    end
  end
end
