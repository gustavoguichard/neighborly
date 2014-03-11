require 'spec_helper'

describe Admin::Channels::MembersController do

  subject{ response }
  let(:admin) { create(:user, admin: true) }
  let(:channel) { create(:channel) }
  let(:current_user){ admin }

  before do
    controller.stub(:current_user).and_return(current_user)
  end

  describe "GET index" do
    context "when I'm not logged in" do
      let(:current_user){ nil }
      before do
        get :index, channel_id: channel
      end
      it{ should redirect_to new_user_session_path }
    end

    context "when I'm logged as admin" do
      before do
        get :index, channel_id: channel
      end
      its(:status){ should == 200 }
    end
  end

  describe "GET new" do
    context "when I'm not logged in" do
      let(:current_user){ nil }
      before do
        get :new, channel_id: channel
      end
      it{ should redirect_to new_user_session_path }
    end

    context "when I'm logged as admin" do
      before do
        get :new, channel_id: channel
      end
      its(:status){ should == 200 }
    end
  end

  describe "POST create" do
    context "when I'm not logged in" do
      let(:current_user){ nil }
      before do
        post :create, channel_id: channel
      end
      it{ should redirect_to new_user_session_path }
    end

    context "when I'm logged as admin" do
      let(:user) { create(:user) }

      context 'when the user does not exists' do
        before do
          post :create, channel_id: channel, user_id: 'not_exist'
        end

        it { expect(flash.alert).to eq(I18n.t('admin.channels.members.messages.user_not_found')) }
        it { should redirect_to admin_channel_members_path(channel) }
      end

      context 'when the user has not channel' do
        before do
          post :create, channel_id: channel, user_id: user.id
        end

        it 'should assign the user to the channel' do
          expect(channel.members).to eq [user]
        end

        it { expect(flash.notice).to eq(I18n.t('admin.channels.members.messages.success')) }
        it { should redirect_to admin_channel_members_path(channel) }
      end

      context 'when the user has a channel' do
        before do
          channel.members << user
          channel.save
          post :create, channel_id: channel, user_id: user.id
        end

        it { expect(flash.alert).to eq(I18n.t('admin.channels.members.messages.already_a_member')) }
        it { should redirect_to admin_channel_members_path(channel) }
      end
    end
  end

  describe "DELETE destroy" do
    let(:user) { create(:user) }
    before { channel.members << user; channel.save }

    context "when I'm not logged in" do
      let(:current_user){ nil }
      before do
        delete :destroy, id: user, channel_id: channel
      end
      it{ should redirect_to new_user_session_path }
    end

    context "when I'm logged as admin" do
      before { delete :destroy, id: user, channel_id: channel }

      it{ should redirect_to admin_channel_members_path(channel) }

      it 'should remove the user from channel members' do
        expect(channel.reload.members).to eq []
      end
    end
  end

end
