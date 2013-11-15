class ChannelDecorator < Draper::Decorator
  decorates :channel

  def image_url
    "channels/#{source.permalink}.png"
  end

end
