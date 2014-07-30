require 'spec_helper'

describe Channels::ProjectsController do
  let(:channel) { create(:channel) }
  let(:project) { build(:project) }

  before do
    @request.host = "#{channel.to_param}.example.com"
  end

  context 'authorized' do
    before do
      sign_in channel.user
    end

    describe 'create' do
      it 'creates a new project' do
        expect {
          post :create, project: project.attributes
        }.to change(Project, :count).by(1)
      end

      it 'associates new project with the given channel' do
        expect {
          post :create, project: project.attributes
        }.to change(channel.projects, :count).by(1)
      end
    end
  end
end
