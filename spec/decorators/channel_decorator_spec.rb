require 'spec_helper'

describe ChannelDecorator do
  subject { described_class.new(channel) }
  let(:channel) { Channel.new }

  describe '#display_video_embed_url' do
    subject{ channel.display_video_embed_url }

    context 'source has a Vimeo video' do
      let(:channel) { create(:channel, video_url: 'http://vimeo.com/17298435') }
      it { should == '//player.vimeo.com/video/17298435?title=0&byline=0&portrait=0&autoplay=0&color=ffffff&badge=0&modestbranding=1&showinfo=0&border=0&controls=2' }
    end

    context 'source has an Youtube video' do
      let(:channel) { create(:channel, video_url: "http://www.youtube.com/watch?v=Brw7bzU_t4c") }
      it { should == '//www.youtube.com/embed/Brw7bzU_t4c?title=0&byline=0&portrait=0&autoplay=0&color=ffffff&badge=0&modestbranding=1&showinfo=0&border=0&controls=2' }
    end

    context 'source does not have a video' do
      let(:channel) { create(:channel, video_url: "") }
      it { should be_nil }
    end
  end

  describe 'application_url' do
    it 'returns the model attribute when present in source' do
      url = 'http://example.com/application.pdf'
      channel.application_url = url
      expect(subject.application_url).to eql(url)
    end

    it 'returns new_project_path when not present in source' do
      channel.application_url = nil
      expect(subject.application_url).to eql(Rails.application.routes.url_helpers.new_project_path)
    end
  end
end

