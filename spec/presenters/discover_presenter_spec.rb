require 'spec_helper'

describe DiscoverPresenter do
  let(:params) { {} }
  subject      { described_class.new(params) }

  describe 'delegations' do
    it { should delegate_method(:projects).to(:discover) }
    it { should delegate_method(:filters).to(:discover) }
  end

  describe '#tags' do
    it 'loads the popular tags' do
      expect(Tag).to receive(:popular)
      subject.tags
    end
  end

  describe '#channels' do
    let!(:channel) { create(:channel, state: 'online') }

    context 'when filters are empty' do
      it 'loads channels with filtering by online' do
        expect(Channel).to receive(:with_state).with('online').and_call_original
        subject.channels
      end

      it 'returns an array' do
        expect(subject.channels).to eq [channel]
      end
    end

    context 'when filters are not empty' do
      let(:params) { { state: :recommended } }

      it 'does not loads the channels' do
        expect(Channel).not_to receive(:with_state)
        subject.channels
      end

      it 'returns a empty array' do
        expect(subject.channels).to eq []
      end
    end
  end

  describe '#categories' do
    it 'loads categories with projects' do
      expect(Category).to receive(:with_projects)
      subject.categories
    end
  end

  describe '#locations' do
    it 'calls locations on Projects' do
      expect(Project).to receive(:locations)
      subject.locations
    end
  end

  describe '#available_states' do
    it 'translates the states' do
      expect(I18n).to receive(:t).at_least(Discover::STATES.size)
      subject.available_states
    end
  end

  describe '#must_show_all_projects' do
    context 'when show_all_projects params is true' do
      let(:params) { { show_all_projects: 'true' } }
      it 'returns true' do
        expect(subject.must_show_all_projects).to eq true
      end
    end

    context 'when search params is present' do
      let(:params) { { search: 'testing' } }
      it 'returns true' do
        expect(subject.must_show_all_projects).to eq true
      end
    end

    context 'when show_all_projects is false' do
      let(:params) { { show_all_projects: 'false' } }
      it 'returns false' do
        expect(subject.must_show_all_projects).to eq false
      end
    end

    context 'when no params is present' do
      let(:params) { { } }
      it 'returns false' do
        expect(subject.must_show_all_projects).to eq false
      end
    end
  end
end
