require 'spec_helper'

describe ImagesController do

  describe 'GET \'new\'' do
    context 'when I am not logged in' do
      it 'requires login' do
        get :new
        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'when I am logged in' do
      before { sign_in create(:user) }

      it 'success request' do
        get :new
        expect(response).to be_success
      end
    end
  end

  describe 'POST \'create\'' do
    context 'when I am not logged in' do
      it 'requires login' do
        post :create
        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'when I am logged in' do
      let(:current_user) { create(:user) }
      before { sign_in current_user }

      context 'when succeed' do
        before do
          post :create, image: { file:
                                 fixture_file_upload('spec/fixtures/image.png',
                                                     'image/png') },
                        format: :json
        end

        it 'returns a json with image url' do
          json = { status: :success,
                   :"image[file]" => assigns(:image).file_url(:medium) }.to_json

          expect(response.body).to eq json
        end

        it 'creates an image object' do
          expect(Image.all.size).to eq 1
        end

        it 'assigns current_user to image' do
          expect(assigns(:image).user).to eq current_user
        end
      end

      context 'when fails' do
        before do
          post :create, image: { }, format: :json
        end

        it 'returns a json with error status' do
          json = { status: :error }.to_json

          expect(response.body).to eq json
        end

        it 'not creates an image object' do
          expect(Image.all.size).to eq 0
        end
      end
    end
  end

end
