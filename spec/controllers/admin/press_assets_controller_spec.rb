require 'spec_helper'

describe Admin::PressAssetsController do
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
    let(:press_asset) { create(:press_asset) }
    context "when I'm not logged in" do
      let(:current_user){ nil }
      before do
        get :edit, id: press_asset
      end
      it{ should redirect_to new_user_session_path }
    end

    context "when I'm logged as admin" do
      before do
        get :edit, id: press_asset
      end
      its(:status){ should == 200 }

      it 'should assigns the correct resource' do
        expect(assigns(:press_asset)).to eq press_asset
      end
    end
  end

  describe "PUT update" do
    let(:press_asset) { create(:press_asset) }

    context "when I'm not logged in" do
      let(:current_user){ nil }
      before do
        put :update, id: press_asset
      end
      it{ should redirect_to new_user_session_path }
    end

    context "when I'm logged as admin" do
      before do
        put :update, id: press_asset, press_asset: { title: 'updated title!' }
      end

      it{ should redirect_to admin_press_assets_path }

      it 'should update press_asset title' do
        expect(press_asset.reload.title).to eq 'updated title!'
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
        post :create, press_asset: build(:press_asset).attributes.merge(image: Rack::Test::UploadedFile.new("#{Rails.root}/spec/fixtures/image.png"))
      end

      it{ should redirect_to admin_press_assets_path }

      it 'should create a new press_asset' do
        expect(PressAsset.all).to have(1).press_asset
      end
    end
  end

  describe "DELETE destroy" do
    let(:press_asset) { create(:press_asset) }

    context "when I'm not logged in" do
      let(:current_user){ nil }
      before do
        delete :destroy, id: press_asset
      end
      it{ should redirect_to new_user_session_path }
    end

    context "when I'm logged as admin" do
      before { delete :destroy, id: press_asset }

      it{ should redirect_to admin_press_assets_path }

      it 'should destroy the press_asset' do
        expect{ press_asset.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end


