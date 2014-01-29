require 'spec_helper'

describe Admin::Companies::ContactsController do
  let(:current_user){ create(:user, admin: true) }
  let(:company_contact) { create(:company_contact) }

  before do
    controller.stub(:current_user).and_return(current_user)
  end

  describe "GET 'index'" do
    before { get :index }
    it { expect(response).to be_success }
    it { expect(assigns(:contacts)).to eq [company_contact] }
  end

  describe "GET 'show'" do
    before { get :show, id: company_contact }
    it { expect(response).to be_success }
    it { expect(assigns(:contact)).to eq company_contact }
  end

end
