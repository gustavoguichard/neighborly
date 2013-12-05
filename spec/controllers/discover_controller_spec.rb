require 'spec_helper'

describe DiscoverController do
  before do
    @recommended = create(:project, recommended: true)
    @near = create(:project, address: 'Kansas City, MO', latitude: 40.7143528, longitude: -74.0059731)
    @category = create(:category)
    @category_project = create(:project, category: @category)
    @tag = create(:project, tag_list: 'test')
    @search = create(:project, name: 'test project for search')
    create(:channel, state: 'online')
    create(:channel, state: 'draft')
  end

  it 'should have the rights filters' do
    expect(DiscoverController::FILTERS).to eq [ 'recommended', 'expiring', 'recent', 'successful', 'soon' ]
  end

  shared_examples 'has filter' do
    it 'should not assings channels when has filter' do
      expect(assigns(:channels)).to be_nil
    end

    it 'should assigns filter' do
      expect(assigns(:filters)).to have(1).filter
    end
  end

  describe 'GET index' do
    context 'when access without filter' do
      before { get :index }

      it 'shoult get all project' do
        expect(assigns(:projects).to_a).to have(5).items
      end

      it 'should assigns online channels' do
        expect(assigns(:channels)).to have(1).channel
      end
    end

    context 'when filtering by recommended' do
      before { get :index, filter: :recommended }

      it 'should only assigns the recommended project' do
        expect(assigns(:projects)).to eq [@recommended]
      end

      it_behaves_like 'has filter'
    end

    context 'when filtering by near' do
      before { get :index, near: 'Kansas City, MO' }

      it 'should only assings the near project' do
        expect(assigns(:projects)).to eq [@near]
      end

      it_behaves_like 'has filter'
    end

    context 'when filtering by category' do
      before { get :index, category: @category.to_s }

      it 'should only assings the right categorized project' do
        expect(assigns(:projects)).to eq [@category_project]
      end

      it_behaves_like 'has filter'
    end

    context 'when filtering by tags' do
      before { get :index, tags: 'test' }

      it 'should only assings the right taged project' do
        expect(assigns(:projects)).to eq [@tag]
      end

      it_behaves_like 'has filter'
    end

    context 'when searching by a project name' do
      before { get :index, search: 'test project for search' }

      it 'should only assings the right project' do
        expect(assigns(:projects)).to eq [@search]
      end

      it_behaves_like 'has filter'
    end

  end
end
