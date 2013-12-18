require 'spec_helper'

describe Authorization do
    let(:oauth_data){
    Hashie::Mash.new({
      credentials: {
        expires: true,
        expires_at: 1366644101,
        token: "AAAHuZCwF61OkBAOmLTwrhv52pZCriPnTGIasdasdasdascNhZCZApsZCSg6POZCQqolxYjnqLSVH67TaRDONx72fXXXB7N7ZBByLZCV7ldvagm"
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
    it{ should validate_presence_of :user }
    it{ should validate_presence_of :uid }
  end

  describe ".find_from_hash" do
    context 'when the provider is google_oauth2' do
      let(:user){ create(:user, email: oauth_data['info']['email']) }
      before do
        provider = create(:oauth_provider, name: 'google_oauth2')
        @oauth_data = oauth_data
        @oauth_data['provider'] = 'google_oauth2'
        @authotization = create(:authorization, oauth_provider: provider, uid: 'some other random uid', user: user)
        create(:authorization, oauth_provider: provider)
      end
      subject{ Authorization.find_from_hash(@oauth_data) }
      it{ should == @authotization }
      it{ expect(subject.user).to eq user }
    end

    context 'when the provider is not google_oauth2' do
      before do
        provider = create(:oauth_provider, name: oauth_data[:provider])
        @authotization = create(:authorization, oauth_provider: provider, uid: oauth_data[:uid])
        create(:authorization, oauth_provider: provider)
      end
      subject{ Authorization.find_from_hash(oauth_data) }
      it{ should == @authotization }
    end
  end

  describe ".create_from_hash" do
    before do
      create(:oauth_provider, name: oauth_data[:provider])
    end

    subject{ Authorization.create_from_hash(oauth_data, user) }

    context "when user exists" do
      let(:user){ create(:user, email: oauth_data['info']['email']) }
      it{ should be_persisted }
      its(:uid){ should == oauth_data['uid'] }
      its(:user){ should == user }
    end

    context "when user is new" do
      let(:user){}
      it{ should be_persisted }
      its(:uid){ should == oauth_data['uid'] }
      its(:user){ should be_persisted }
    end
  end

  describe ".create_without_email_from_hash" do
    before do
      create(:oauth_provider, name: oauth_data[:provider])
      @oauth_data = oauth_data
      @oauth_data['info']['email'] = nil
    end

    subject{ Authorization.create_without_email_from_hash(@oauth_data, user) }

    context "when user exists" do
      let(:user){ create(:user) }
      it{ should be_persisted }
      its(:uid){ should == oauth_data['uid'] }
      its(:user){ should == user }
    end

    context "when user is new" do
      let(:user){ nil }
      it{ should be_persisted }
      its(:uid){ should == oauth_data['uid'] }
      its(:user){ should be_persisted }
      it { expect(subject.user.email).to match(/change-your-email\+[0-9]+@neighbor\.ly/) }
      it { expect(subject.user.confirmed?).to be_true }
    end
  end
end
