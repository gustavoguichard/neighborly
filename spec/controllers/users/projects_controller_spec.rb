require 'spec_helper'

describe Users::ProjectsController do
  let(:user) { create(:user) }
  let(:project) { create(:project, user: user) }

  subject{ response }

  before do
    controller.stub(:current_user).and_return(user)
  end

  describe "GET index" do
    before do
      get :index, { user_id: project.user_id }
    end
    its(:status){ should eq 200 }
  end
end
