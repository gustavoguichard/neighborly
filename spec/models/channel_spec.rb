require 'spec_helper'

describe Channel do
  describe "Validations & Assoaciations" do

    [:name, :description, :permalink, :user].each do |attribute|
      it { should validate_presence_of      attribute }
    end

    it "validates uniqueness of permalink" do
      # Creating a channel profile before, to check its uniqueness
      # Because permalink is also being validated on Database with not
      # NULL constraint
      create(:channel)
      should validate_uniqueness_of :permalink
    end


    it { should have_many :subscriber_reports }
    it { should have_many :channels_subscribers }
    it { should belong_to :user }
    it { should have_and_belong_to_many :projects }
    it { should have_and_belong_to_many :subscribers }
    it { should have_many :channel_members }
    it { should have_many :members }
  end

  describe ".by_permalink" do
    before do
      @c1 = create(:channel, permalink: 'foo')
      @c2 = create(:channel, permalink: 'bar')
    end

    subject { Channel.by_permalink('foo') }

    it { should == [@c1] }
  end

  describe '.find_by_permalink!' do
    before do
      @c1 = create(:channel, permalink: 'Foo')
      @c2 = create(:channel, permalink: 'bar')
    end

    subject { Channel.find_by_permalink!('foo') }

    it { should == @c1 }
  end


  describe "#to_param" do
    let(:channel) { create(:channel) }
    it "should return the permalink" do
      expect(channel.to_param).to eq(channel.permalink)
    end
  end


  describe "#has_subscriber?" do
    let(:channel) { create(:channel) }
    let(:user) { create(:user) }
    subject{ channel.has_subscriber? user }

    context "when user is nil" do
      let(:user) { nil }
      it{ should be_false }
    end

    context "when user is a channel subscriber" do
      before do
        channel.subscribers = [user]
        channel.save!
      end
      it{ should be_true }
    end

    context "when user is not a channel subscriber" do
      it{ should be_false }
    end
  end

  describe "#projects" do
    let(:channel) { create(:channel) }
    let(:project1) { create(:project, online_date: (Time.now - 21.days)) }
    let(:project2) { create(:project, online_date: (Time.now - 20.days)) }
    before { channel.projects << project1 }
    before { channel.projects << project2 }

    it "should projects in more days online ascending order" do
      expect(channel.projects).to eq([project2, project1])
    end
  end

  describe "#update_video_embed_url" do
    let(:channel) { create(:channel) }
    before do
      channel.video_url = 'http://vimeo.com/49584778'
      channel.video.should_receive(:embed_url).and_call_original
      channel.update_video_embed_url
    end

    it "should store the new embed url" do
      channel.video_embed_url.should == 'player.vimeo.com/video/49584778'
    end
  end
end
