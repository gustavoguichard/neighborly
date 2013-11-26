require 'spec_helper'

describe ChannelDecorator do
  let(:channel){ build(:channel, facebook: 'http://www.facebook.com/foobar', twitter: 'http://twitter.com/foobar', website: 'http://foobar.com') }

  describe "#display_facebook" do
    subject{ channel.display_facebook }
    it{ should eq('foobar') }
  end

  describe "#display_twitter" do
    subject{ channel.display_twitter }
    it{ should eq('@foobar') }
  end

  describe "#display_website" do
    subject{ channel.display_website }
    it{ should eq('foobar.com') }
  end

  describe '#display_video_embed_url' do
    subject{ channel.display_video_embed_url }

    context 'source has a Vimeo video' do
      let(:channel) { create(:channel, video_url: 'http://vimeo.com/17298435') }
      it { should == '//player.vimeo.com/video/17298435?title=0&byline=0&portrait=0&autoplay=0' }
    end

    context 'source has an Youtube video' do
      let(:channel) { create(:channel, video_url: "http://www.youtube.com/watch?v=Brw7bzU_t4c") }
      it { should == '//www.youtube.com/embed/Brw7bzU_t4c?title=0&byline=0&portrait=0&autoplay=0' }
    end

    context 'source does not have a video' do
      let(:channel) { create(:channel, video_url: "") }
      it { should be_nil }
    end
  end
end

