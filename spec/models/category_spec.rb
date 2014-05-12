require 'spec_helper'

describe Category do
  describe 'associations' do
    it { should have_many :projects }
  end

  describe 'validations' do
    it { should validate_presence_of :name_pt }
    it do
      create(:category)
      should validate_uniqueness_of :name_pt
    end
  end

  describe '.with_projects' do
    let(:category) { create(:category) }

    context 'when category has a project' do
      let!(:project) { create(:project, category: category) }

      it 'returns categories with projects' do
        expect(described_class.with_projects).to eq [category]
      end
    end

    context 'when category has no project' do
      it 'returns an empty array' do
        expect(described_class.with_projects).to eq []
      end
    end
  end

  describe '.array' do
    it 'returns an array with categories' do
      category = create(:category)
      expect(described_class.array).to eq [['Select an option', ''],
                                           [category.name_en, category.id]]
    end
  end
end
