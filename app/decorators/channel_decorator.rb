class ChannelDecorator < Draper::Decorator
  decorates :channel

  def display_video_embed_url
    "//#{source.video_embed_url}?title=0&byline=0&portrait=0&autoplay=0&color=ffffff&badge=0&modestbranding=1&showinfo=0&border=0&controls=2".gsub('http://', '') if source.video_embed_url
  end

  private
  def last_fragment(uri)
    uri.split("/").last
  end
end
