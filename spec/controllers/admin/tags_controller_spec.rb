require 'spec_helper'

describe Admin::TagsController do
  subject{ response }
  let(:admin) { create(:user, admin: true) }
  let(:current_user){ admin }

  before do
    controller.stub(:current_user).and_return(current_user)
  end

  describe "GET index" do
    context "when I'm not logged in" do
      let(:current_user){ nil }
      before do
        get :index
      end
      it{ should redirect_to new_user_session_path }
    end

    context "when I'm logged as admin" do
      before do
        get :index
      end
      its(:status){ should == 200 }
    end
  end

  describe "GET edit" do
    let(:tag) { create(:tag) }
    context "when I'm not logged in" do
      let(:current_user){ nil }
      before do
        get :edit, id: tag
      end
      it{ should redirect_to new_user_session_path }
    end

    context "when I'm logged as admin" do
      before do
        get :edit, id: tag
      end
      its(:status){ should == 200 }

      it 'should assigns the correct resource' do
        expect(assigns(:tag)).to eq tag
      end
    end
  end

  describe "PUT update" do
    let(:tag) { create(:tag) }

    context "when I'm not logged in" do
      let(:current_user){ nil }
      before do
        put :update, id: tag
      end
      it{ should redirect_to new_user_session_path }
    end

    context "when I'm logged as admin" do
      before do
        put :update, id: tag, tag: { name: 'updated name!' }
      end

      it{ should redirect_to admin_tags_path }

      it 'should update tag name' do
        expect(tag.reload.name).to eq 'updated name!'
      end
    end
  end

  describe "GET new" do
    context "when I'm not logged in" do
      let(:current_user){ nil }
      before do
        get :new
      end
      it{ should redirect_to new_user_session_path }
    end

    context "when I'm logged as admin" do
      before do
        get :new
      end
      its(:status){ should == 200 }
    end
  end

  describe "POST create" do
    context "when I'm not logged in" do
      let(:current_user){ nil }
      before do
        post :create
      end
      it{ should redirect_to new_user_session_path }
    end

    context "when I'm logged as admin" do
      before do
        post :create, tag: build(:tag).attributes
      end

      it{ should redirect_to admin_tags_path }

      it 'should create a new tag' do
        expect(Tag.all).to have(1).tag
      end
    end
  end

  describe "DELETE destroy" do
    let(:tag) { create(:tag) }

    context "when I'm not logged in" do
      let(:current_user){ nil }
      before do
        delete :destroy, id: tag
      end
      it{ should redirect_to new_user_session_path }
    end

    context "when I'm logged as admin" do
      before { delete :destroy, id: tag }

      it{ should redirect_to admin_tags_path }

      it 'should destroy the tag' do
        expect{ tag.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end

