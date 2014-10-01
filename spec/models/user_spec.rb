require 'spec_helper'

describe User do
  before { UserUploader.any_instance.stub(:download!) }
  let(:user){ create(:user) }
  let(:unfinished_project){ create(:project, state: 'online') }
  let(:successful_project){ create(:project, state: 'online') }
  let(:failed_project){ create(:project, state: 'online') }
  let(:facebook_provider){ create :oauth_provider, name: 'facebook' }

  describe "associations" do
    it{ should have_many :contributions }
    it{ should have_many :projects }
    it{ should have_many :notifications }
    it{ should have_many :authorizations }
    it{ should have_many(:oauth_providers).through(:authorizations) }
    it{ should have_many :channels_subscribers }
    it{ should have_and_belong_to_many :subscriptions }
    it{ should have_one :channel }
    it{ should have_one :organization }
    it{ should have_many :channel_members }
    it{ should have_many :channels }
    it{ should have_one :investment_prospect }
  end

  describe "validations" do
    before{ user }
    it{ should allow_value('foo@bar.com').for(:email) }
    it{ should_not allow_value('foo').for(:email) }
    it{ should_not allow_value('foo@bar').for(:email) }
    it{ should allow_value('a'.center(139)).for(:bio) }
    it{ should allow_value('a'.center(140)).for(:bio) }
    it{ should_not allow_value('a'.center(141)).for(:bio) }
    it{ should validate_uniqueness_of(:email) }

    describe 'password' do
      context 'when is not someone into early access for bonds' do
        it 'does require it when is a new record' do
          expect(subject).to be_password_required
        end

        it 'does require it when password confirmation were filled' do
          subject.password_confirmation = '123123123'
          expect(subject).to be_password_required
        end
      end

      context 'when is someone into early access for bonds' do
        before { subject.bonds_early_adopter = true }

        it 'doesn\'t require it when is new user' do
          expect(subject).to_not be_password_required
        end

        it 'does require it when updating existing user' do
          subject = create(:user)
          expect(subject).to be_password_required
        end
      end
    end
  end

  describe "profile_types" do
    let(:user) { create(:user) }

    describe "#personal?" do
      subject { user.personal? }

      context "when user is new" do
        it { should be_true }
      end
    end

    describe "#organization?" do
      let(:user) { create(:user, profile_type: 'organization') }

      subject { user.organization? }

      context "when change profile_type to organization" do
        it { should be_true }
      end
    end
  end

  describe '#pg_search' do
    let(:user) { create(:user, name: 'foo') }
    context 'when user exists' do
      it 'returns the user ignoring accents' do
        expect(
          [described_class.pg_search('foo'), described_class.pg_search('fóõ')]
        ).to eq [[user], [user]]
      end
    end
    context 'when user is not found' do
      it 'returns a empty array' do
        expect(described_class.pg_search('lorem')).to eq []
      end
    end
  end

  describe ".who_contributed_project" do
    subject{ User.who_contributed_project(successful_project.id) }
    before do
      @contribution = create(:contribution, state: 'confirmed', project: successful_project)
      create(:contribution, state: 'confirmed', project: successful_project, user: @contribution.user)
      create(:contribution, state: 'pending', project: successful_project)
    end
    it{ should == [@contribution.user] }
  end

  describe ".create" do
    subject do
      User.create! do |u|
        u.email = 'diogob@gmail.com'
        u.password = '123456'
        u.twitter_url = 'http://twitter.com/dbiazus'
        u.facebook_url = 'http://facebook.com/test'
      end
    end
    its(:twitter_url){ should == 'http://twitter.com/dbiazus' }
    its(:facebook_url){ should == 'http://facebook.com/test' }
  end

  describe "#total_contributed_projects" do
    let(:user) { create(:user) }
    let(:project) { create(:project) }
    subject { user.total_contributed_projects }

    before do
      create(:contribution, state: 'confirmed', user: user, project: project)
      create(:contribution, state: 'confirmed', user: user, project: project)
      create(:contribution, state: 'confirmed', user: user, project: project)
      create(:contribution, state: 'confirmed', user: user)
    end

    it { should == 2}
  end

  describe "#recommended_project" do
    subject{ user.recommended_projects }
    before do
      other_contribution = create(:contribution, state: 'confirmed')
      create(:contribution, state: 'confirmed', user: other_contribution.user, project: unfinished_project)
      create(:contribution, state: 'confirmed', user: user, project: other_contribution.project)
    end
    it{ should == [unfinished_project]}
  end

  describe "#facebook_id" do
    subject{ user.facebook_id }
    context "when user have a FB authorization" do
      let(:user){ create(:user, authorizations: [ create(:authorization, uid: 'bar', oauth_provider: facebook_provider)]) }
      it{ should == 'bar' }
    end
    context "when user do not have a FB authorization" do
      let(:user){ create(:user) }
      it{ should == nil }
    end
  end

  describe "#total_contributions" do
    let(:user){ create(:user) }
    subject { user.total_contributions }

    context "without contributions" do
      it { expect(subject).to be_zero }
    end

    context "with not anonymous contributions" do
      context "with confirmed status" do
        before { create(:contribution, user: user, state: 'confirmed', anonymous: false) }

        it { expect(subject).to eq(1) }
      end

      context "with pending status" do
        before { create(:contribution, user: user, state: 'pending', anonymous: false) }

        it { expect(subject).to be_zero }
      end
    end

    context "with anonymous contributions" do
      context "with confirmed status" do
        before { create(:contribution, user: user, state: 'confirmed', anonymous: true) }

        it { expect(subject).to be_zero }
      end

      context "with pending status" do
        before { create(:contribution, user: user, state: 'pending', anonymous: true) }

        it { expect(subject).to be_zero }
      end
    end
  end

  describe "#total_led" do
    let(:user){ create(:user) }
    subject { user.total_led }

    context "not visible projects" do
      before { create(:project, user: user, state: 'rejected') }

      it { expect(subject).to be_zero }
    end

    context "visible projects" do
      context "soon projects" do
        before { create(:project, user: user, state: 'soon') }

        it { expect(subject).to be_zero }
      end

      context "not soon projects" do
        before { create(:project, user: user, state: 'online') }

        it { expect(subject).to eq(1) }
      end
    end
  end
end
