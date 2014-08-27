module Project::VideoHandler
  extend ActiveSupport::Concern

  included do
    mount_uploader :video_thumbnail, ProjectUploader, mount_on: :video_thumbnail

    delegate :display_video_embed_url, to: :decorator

    def download_video_thumbnail
      if video_valid?
        self.video_thumbnail = open(video.thumbnail_large)
        save
      end
    end

    def update_video_embed_url
      if video_valid?
        self.video_embed_url = video.embed_url
        save
      end
    end

    protected

    def video_valid?
      VideoInfo.usable?(video_url)
    end

    def video
      @video ||= VideoInfo.get(video_url)
    end
  end
end
