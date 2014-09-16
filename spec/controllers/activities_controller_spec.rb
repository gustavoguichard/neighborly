require 'spec_helper'

describe ActivitiesController do
  let(:current_user)        { create(:user, admin: true)}
  let(:project)             { create(:project, user: current_user) }
  let(:activity)            { create(:activity, project: project, user: current_user) }
  let(:activity_attributes) { build(:activity).attributes }

  before do
    controller.stub(:current_user).and_return(current_user)
  end

  describe '#new' do
    it 'assigns a new activity as @activity' do
      get :new, project_id: project
      expect(assigns(:activity)).to be_a_new(Activity)
    end
  end

  describe '#edit' do
    it 'assigns the requested activity as @activity' do
      get :edit, id: activity.to_param, project_id: project
      expect(assigns(:activity)).to eq(activity)
    end
  end

  describe '#create' do
    describe 'with valid params' do
      it 'creates a new Activity' do
        expect {
          post :create, activity: activity_attributes, project_id: project
        }.to change(Activity, :count).by(1)
      end

      it 'assigns a newly created activity as @activity' do
        post :create, activity: activity_attributes, project_id: project
        expect(assigns(:activity)).to be_a(Activity)
        expect(assigns(:activity)).to be_persisted
      end

      it 'redirects to the project page' do
        post :create, activity: activity_attributes, project_id: project
        expect(response).to  redirect_to(project_path(project))
      end
    end

    describe 'with invalid params' do
      it 'assigns a newly created but unsaved activity as @activity' do
        Activity.any_instance.stub(:save).and_return(false)
        post :create, activity: activity_attributes, project_id: project
        expect(assigns(:activity)).to be_a_new(Activity)
      end
    end
  end

  describe '#update' do
    describe 'with valid params' do
      it 'updates the requested activity' do
        expect_any_instance_of(Activity).to receive(:update).with({ 'title' => 'New Foo Bar' })
        put :update, id: activity, project_id: project, activity: { title: 'New Foo Bar' }
      end

      it 'assigns the requested activity as @activity' do
        put :update, id: activity, project_id: project, activity: { title: 'New Foo Bar' }
        expect(assigns(:activity)).to eq(activity)
      end

      it 'redirects to project page' do
        put :update, id: activity, project_id: project, activity: { title: 'New Foo Bar' }
        expect(response).to redirect_to(project_path(project))
      end
    end

    describe 'with invalid params' do
      it 'assigns the activity as @activity' do
        Activity.any_instance.stub(:save).and_return(false)
        put :update, id: activity, project_id: project, activity: { title: '' }
        expect(assigns(:activity)).to eq(activity)
      end
    end
  end

  describe '#destroy' do
    it 'destroys the requested activity' do
      delete :destroy, id: activity, project_id: project
      expect { activity.reload }.to raise_error
    end

    it 'redirects to project page' do
      delete :destroy, id: activity, project_id: project
      expect(response).to redirect_to(project_path(project))
    end
  end
end
