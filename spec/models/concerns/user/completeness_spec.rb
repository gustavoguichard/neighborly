require 'spec_helper'

describe User::Completeness do

  subject { User::Completeness::Calculator.new(user).progress }

  context 'when the profile type is personal' do
    let(:user) { create(:user, name: 'Some name', bio: nil, address: '', uploaded_image: nil, authorizations: [], profile_type: 'personal') }

    it 'completeness progress should be 20' do
      expect(subject).to eq 20
    end
  end

  context 'when the profile type is organization' do
    let(:user) { create(:user, bio: 'Some Bio', address: '', authorizations: [], organization: create(:organization, name: 'Some Org', image: nil), profile_type: 'organization') }

    it 'completeness progress should be 40' do
      expect(subject).to eq 40
    end
  end

  pending 'when the profile type is channel' do
    let(:user) {  create(:channel, name: 'Some Channel', description: 'Some other text here', user: create(:user, name: nil, other_url: nil, address: 'Kansas City, MO', profile_type: 'channel')).user.reload }

    it 'completeness progress should be 42' do
      expect(subject).to eq 42
    end
  end

  describe '#update_completeness_progress' do
    let(:user) { create(:user, name: 'Some name', profile_type: 'personal') }

    before { user.update_completeness_progress! }
    it { expect(user.reload.completeness_progress).to_not eq 0 }
  end

end
