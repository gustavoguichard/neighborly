require 'spec_helper'

describe Users::AuthorizationsController do
  let(:user) { create(:user) }
  let(:authorization) { create(:authorization, user: user) }

  context 'Not authenticated' do
    before { delete :destroy, id: authorization.id, user_id: user }
    it { expect(response).to redirect_to(new_user_session_path) }
    it { expect(-> { authorization.reload }).not_to raise_error(ActiveRecord::RecordNotFound) }
  end

  context 'Authenticated' do
    before do
      controller.stub(:current_user).and_return(user)
      delete :destroy, id: authorization.id, user_id: user
    end

    it { expect(response).to redirect_to(edit_user_path(user)) }
    it { expect(-> { authorization.reload }).to raise_error(ActiveRecord::RecordNotFound) }
  end
end
