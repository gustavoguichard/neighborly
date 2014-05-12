require 'spec_helper'

describe Projects::MatchesController do
  let(:project) { create(:project, state: :online, online_date: Date.current, online_days: 30) }
  let(:user)    { create(:user) }
  let(:create_params) do
    {
      'match' => {
        'value_unit'  => '3',
        'starts_at'   => Date.tomorrow.to_time.strftime('%m/%d/%y'),
        'finishes_at' => (Date.tomorrow + 2.days).to_time.strftime('%m/%d/%y'),
        'value'       => '9999'
      }
    }
  end

  context 'authorized' do
    before { sign_in(user) }

    describe 'GET \'new\'' do
      it 'assigns match variable' do
        get :new, project_id: project.to_param
        expect(assigns(:match)).to_not be_nil
      end

      it 'renders match template' do
        get :new, project_id: project.to_param
        expect(response).to render_template('projects/matches/new')
      end
    end

    describe 'POST \'create\'' do
      it 'creates a new match' do
        expect {
          post :create, create_params.merge(project_id: project.to_param)
        }.to change(Match, :count).by(1)
      end

      it 'redirects to project page' do
        post :create, create_params.merge(project_id: project.to_param)
        expect(response).to redirect_to(edit_project_match_path(project, Match.last))
      end
    end

    describe 'GET \'edit\'' do
      let(:match) { create(:match, project: project) }
      it 'assigns match variable' do
        get :edit, project_id: project, id: match.id
        expect(assigns(:match)).to_not be_nil
      end

      it 'assigns project variable' do
        get :edit, project_id: project, id: match.id
        expect(assigns(:project)).to_not be_nil
      end
    end

    describe 'GET \'show\'' do
      let(:match) { create(:match, project: project) }
      it 'assigns match variable' do
        get :show, project_id: project, id: match.id
        expect(assigns(:match)).to_not be_nil
      end

      it 'assigns project variable' do
        get :show, project_id: project, id: match.id
        expect(assigns(:project)).to_not be_nil
      end
    end
  end

  context 'unsigned in' do
    describe 'GET \'new\'' do
      it 'asks for user to login' do
        get :new, project_id: project.to_param
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'POST \'create\'' do
      it 'asks for user to login' do
        post :create, create_params.merge(project_id: project.to_param)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'GET \'edit\'' do
      it 'asks for user to login' do
        get :edit, project_id: project, id: 1
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'GET \'show\'' do
      it 'asks for user to login' do
        get :show, project_id: project, id: 1
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
