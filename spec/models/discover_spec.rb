require 'spec_helper'

describe Discover do
  before do
    @category         = create(:category)
    @recommended      = create(:project, recommended: true)
    @category_project = create(:project, category: @category)
    @tag              = create(:project, tag_list: 'test,test2')
    @search           = create(:project, name: 'test project for search')
    @near             = create(:project,
                               location: 'New York, NY',
                               latitude: 40.7143528,
                               longitude: -74.0059731)
  end

  let(:params) { {} }
  subject      { described_class.new params }


  it 'should have the rights filters' do
    expected_states = %w(state near category tags search)
    expect(described_class::FILTERS).to eq(expected_states)
  end

  it 'should have the rights states to filter' do
    expected_states = %w(active recommended expiring recent successful soon with_active_matches)
    expect(described_class::STATES).to eq(expected_states)
  end

  shared_examples 'has filter' do
    it 'has filters' do
      subject.projects
      expect(subject.filters.size).to eq 1
    end
  end

  context 'using without filter' do
    let(:params) { {} }

    it 'gets all projects' do
      expect(subject.projects.to_a.size).to eq 5
    end
  end

  context 'filtering by two type of filters' do
    let(:params) { { state: :recommended, category: @category.to_s } }
    before       { @category_project.update_attributes(recommended: true) }

    it 'merges results of multiple scopes' do
      expect(subject.projects).to eq [@category_project]
    end

    it 'has filters' do
      subject.projects
      expect(subject.filters.size).to eq 2
    end
  end

  context 'filtering by recommended' do
    let(:params) { { state: :recommended } }

    it 'returns only the recommended project' do
      expect(subject.projects).to eq [@recommended]
    end

    it_behaves_like 'has filter'
  end

  context 'filtering by near' do
    before do
      [@recommended, @category_project, @tag, @search].each do |p|
        p.latitude = nil
        p.longitude = nil
        p.save(validate: false)
      end
    end

    let(:params) { { near: 'New York, NY' } }

    it 'returns only the near project' do
      expect(subject.projects).to eq [@near]
    end

    it_behaves_like 'has filter'
  end

  context 'filtering by category' do
    let(:params) { { category: @category.to_s } }

    it 'returns only the right categorized project' do
      expect(subject.projects).to eq [@category_project]
    end

    it_behaves_like 'has filter'
  end

  context 'filtering by tags' do
    let(:params) { { tags: 'test,test2' } }

    it 'returns only the right tagged project' do
      expect(subject.projects).to eq [@tag]
    end

    it_behaves_like 'has filter'
  end

  context 'searching by a project name' do
    let(:params) { { search: 'test project for search' } }

    it 'returns only the right project' do
      expect(subject.projects).to eq [@search]
    end

    it_behaves_like 'has filter'
  end
end
