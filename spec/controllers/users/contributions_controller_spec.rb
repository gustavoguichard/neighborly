require 'spec_helper'

describe Users::ContributionsController do
  subject{ response }
  let(:user){ create(:user, password: 'current_password', password_confirmation: 'current_password', authorizations: [create(:authorization, uid: 666, oauth_provider: create(:oauth_provider, name: 'facebook'))]) }
  let(:successful_project){ create(:project, state: 'online', user: user) }
  let(:failed_project){ create(:project, state: 'online') }
  let(:successful_contribution){ create(:contribution, state: 'confirmed', project: successful_project, user: user) }
  let(:failed_contribution){ create(:contribution, state: 'confirmed', user: user, project: failed_project) }
  let(:other_back) { create(:contribution, project: failed_project) }
  let(:unconfirmed_contribution) { create(:contribution, state: 'pending', user: user, project: failed_project) }
  let(:current_user){ nil }
  let(:format){ 'json' }
  before do
    controller.stub(:current_user).and_return(current_user)
    successful_contribution
    failed_contribution
    unconfirmed_contribution
    other_back
    successful_project.update_attributes state: 'successful'
  end

  describe "GET index" do
    let(:current_user){ user }

    before do
      get :index, user_id: successful_contribution.user.id, locale: 'pt'
    end

    its(:status){ should == 200 }
  end
end
