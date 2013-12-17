require 'spec_helper'

describe Admin::ChannelsController do
  subject{ response }
  let(:admin) { create(:user, admin: true) }
  let(:current_user){ admin }

  before do
    controller.stub(:current_user).and_return(current_user)
  end

  describe 'PUT push_to_draft' do
    let(:channel) { create(:channel, state: 'online') }
    subject { channel.draft? }

    before do
      put :push_to_draft, id: channel
      channel.reload
    end

    it { should be_true }
  end

  describe 'PUT push_to_online' do
    let(:channel) { create(:channel, state: 'draft') }
    subject { channel.online? }

    before do
      put :push_to_online, id: channel
      channel.reload
    end

    it { should be_true }
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
    let(:channel) { create(:channel) }
    context "when I'm not logged in" do
      let(:current_user){ nil }
      before do
        get :edit, id: channel
      end
      it{ should redirect_to new_user_session_path }
    end

    context "when I'm logged as admin" do
      before do
        get :edit, id: channel
      end
      its(:status){ should == 200 }

      it 'should assigns the correct resource' do
        expect(assigns(:channel)).to eq channel
      end
    end
  end

  describe "PUT update" do
    let(:channel) { create(:channel) }

    context "when I'm not logged in" do
      let(:current_user){ nil }
      before do
        put :update, id: channel
      end
      it{ should redirect_to new_user_session_path }
    end

    context "when I'm logged as admin" do
      before do
        put :update, id: channel, channel: { name: 'Updated name!' }
      end

      it{ should redirect_to admin_channels_path }

      it 'should create a new channel' do
        expect(channel.reload.name).to eq 'Updated name!'
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
        post :create, channel: build(:channel).attributes
      end

      it{ should redirect_to admin_channels_path }

      it 'should create a new channel' do
        expect(Channel.all).to have(1).channel
      end
    end
  end

  describe "DELETE destroy" do
    let(:channel) { create(:channel, state: 'online') }

    context "when I'm not logged in" do
      let(:current_user){ nil }
      before do
        delete :destroy, id: channel
      end
      it{ should redirect_to new_user_session_path }
    end

    context "when I'm logged as admin" do
      before { delete :destroy, id: channel }

      it{ should redirect_to admin_channels_path }

      it 'should destroy the channel' do
        expect{ channel.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end

