require 'spec_helper'

describe Projects::Challenges::MatchesController do
  let(:project) { create(:project, state: :online, online_date: Date.current, online_days: 30) }
  let(:user)    { create(:user) }

  before { sign_in(user) }

  describe 'GET \'new\'' do
    it 'assigns match variable' do
      get :new, project_id: project.to_param
      expect(assigns(:match)).to_not be_nil
    end

    it 'renders match template' do
      get :new, project_id: project.to_param
      expect(response).to render_template('projects/challenges/matches/new')
    end
  end

  describe 'POST \'create\'' do
    let(:params) do
      {
        "projects_challenges_match" => {
          "value"         => "3",
          "starts_at"     => Date.tomorrow.to_time.strftime('%m/%d/%y'),
          "finishes_at"   => (Date.tomorrow + 2.days).to_time.strftime('%m/%d/%y'),
          "maximum_value" => "9999"
        }
      }
    end

    it 'creates a new match' do
      expect {
        post :create, params.merge(project_id: project.to_param)
      }.to change(Projects::Challenges::Match, :count).by(1)
    end

    it 'redirects to project page' do
      post :create, params.merge(project_id: project.to_param)
      expect(response).to redirect_to(project)
    end
  end
end
