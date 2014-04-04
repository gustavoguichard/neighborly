require 'spec_helper'

describe Authorization do
    let(:oauth_data){
    Hashie::Mash.new({
      credentials: {
        expires: true,
        expires_at: 1366644101,
        token: "AAAHuZCwF61OkBAOmLTwrhv52pZCriPnTGIasdasdasdascNhZCZApsZCSg6POZCQqolxYjnqLSVH67TaRDONx72fXXXB7N7ZBByLZCV7ldvagm",
        secret: 'secret',
        refresh_token: 'refresh_token'
      },
      extra: {
        raw_info: {
          bio: "I, simply am not there",
          email: "diogob@gmail.com",
          first_name: "Diogo",
          gender: "male",
          id: "547955110",
          last_name: "Biazus",
          link: "http://www.facebook.com/diogo.biazus",
          locale: "pt_BR",
          name: "Diogo, Biazus",
          timezone: -3,
          updated_time: "2012-08-01T18:22:50+0000",
          username: "diogo.biazus",
          verified: true
        },
      },
      info: {
        description: "I, simply am not there",
        email: "diogob@gmail.com",
        first_name: "Diogo",
        image: "http://graph.facebook.com/547955110/picture?type:, square",
        last_name: "Biazus",
        name: "Diogo, Biazus",
        nickname: "diogo.biazus",
        urls: {
          Facebook: "http://www.facebook.com/diogo.biazus"
        },
        verified: true
      },
      provider: "facebook",
      uid: "547955110"
    })
  }

  describe "Associations" do
    it{ should belong_to :user }
    it{ should belong_to :oauth_provider }
  end

  describe "Validations" do
    it{ should validate_presence_of :oauth_provider }
    it{ should validate_presence_of :uid }
  end

  describe '#update_access_token_from_hash' do
    let(:authorization) { create(:authorization, oauth_provider: create(:oauth_provider, name: @oauth_data['provider']), uid: @oauth_data['uid']) }
    before do
      @oauth_data = oauth_data
      @oauth_data['provider'] = provider_name
      @authorization = authorization
      @authorization.update_access_token_from_hash(@oauth_data)
    end

    context 'when provider is facebook' do
      let(:provider_name) { 'facebook' }
      subject { @authorization }

      it { expect(subject.access_token).to eq @oauth_data['credentials']['token'] }
      it { expect(subject.access_token_expires_at).to eq Time.at(@oauth_data['credentials']['expires_at'].to_i) }
    end

    context 'when provider is twitter' do
      let(:provider_name) { 'twitter' }
      subject { @authorization }

      it { expect(subject.access_token).to eq @oauth_data['credentials']['token'] }
      it { expect(subject.access_token_secret).to eq @oauth_data['credentials']['secret'] }
    end

    context 'when provider is linkedin' do
      let(:provider_name) { 'linkedin' }
      subject { @authorization }

      it { expect(subject.access_token).to eq @oauth_data['credentials']['token'] }
      it { expect(subject.access_token_secret).to eq @oauth_data['credentials']['secret'] }
    end

    context 'when provider is google_oauth2' do
      let(:provider_name) { 'google_oauth2' }
      subject { @authorization }

      it { expect(subject.access_token).to eq @oauth_data['credentials']['token'] }
      it { expect(subject.access_token_secret).to eq @oauth_data['credentials']['refresh_token'] }
      it { expect(subject.access_token_expires_at).to eq Time.at(@oauth_data['credentials']['expires_at'].to_i) }
    end

    context 'when we do not support a provider' do
      let(:provider_name) { 'some_other_provider' }
      subject { @authorization }

      it { expect(subject.access_token).to be_nil }
      it { expect(subject.access_token_secret).to be_nil }
      it { expect(subject.access_token_expires_at).to be_nil }
    end
  end
end
