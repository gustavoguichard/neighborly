require 'spec_helper'

describe Project::VideoHandler do
  let(:project) { create(:project) }

  describe "#download_video_thumbnail" do
    context 'when there is an url' do
      it "should open the video_url and store it in video_thumbnail" do
        project.should_receive(:download_video_thumbnail).and_call_original
        expect(project).to receive(:open).and_return(File.open("#{Rails.root}/spec/fixtures/image.png"))
        project.download_video_thumbnail
        project.video_thumbnail.url.should == "/uploads/project/video_thumbnail/#{project.id}/image.png"
      end
    end

    context 'when there is no url' do
      it 'does not update the object' do
        project.video_url = ''
        expect(project).to_not receive(:save)
        project.download_video_thumbnail
      end
    end
  end

  describe "#update_video_embed_url" do
    context 'when there is an url' do
      it "should store the new embed url" do
        project.video_url = 'http://vimeo.com/49584778'
        project.update_video_embed_url
        project.video_embed_url.should == 'player.vimeo.com/video/49584778'
      end
    end

    context 'when there is no url' do
      it 'does not update the object' do
        project.video_url = ''
        expect(project).to_not receive(:save)
        project.update_video_embed_url
      end
    end
  end
end
