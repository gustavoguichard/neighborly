require 'spec_helper'

describe DiscoverController do
  before(:all) do
    @recommended = create(:project, recommended: true)
    create(:channel, state: 'online')
    create(:channel, state: 'draft')
  end

  describe 'GET index' do
    context 'when access without filter' do
      before { get :index }

      it 'assigns online channels' do
        expect(assigns(:channels).size).to eq 1
      end
    end

    context 'when access with filter' do
      before { get :index, state: :recommended }

      it 'does not assigns online channels' do
        expect(assigns(:channels)).to be_nil
      end
    end
  end
end
