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

    describe 'new' do
      context 'when channel does have external application method' do
        let(:channel) { create(:channel_with_external_application) }

        it 'raise routing error' do
          expect {
            get :new
          }.to raise_error
        end
      end
    end

    describe 'create' do
      context 'when channel does not have external application method' do
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

      context 'when channel does have external application method' do
        let(:channel) { create(:channel_with_external_application) }

        it 'raise routing error' do
          expect {
            post :create, project: project.attributes
          }.to raise_error
        end
      end
    end
  end
end
