require 'spec_helper'

describe ChannelUploader do
  include CarrierWave::Test::Matchers
  let(:channel){ FactoryGirl.create(:channel) }

  before do
    ChannelUploader.enable_processing = true
    @uploader = ChannelUploader.new(channel, :image)
    @uploader.store!(File.open("#{Rails.root}/spec/fixtures/image.png"))
  end

  after do
    ChannelUploader.enable_processing = false
    @uploader.remove!
  end

  describe '#thumb' do
    subject{ @uploader.thumb }
    it{ should have_dimensions(170, 85) }
  end

  describe '#large' do
    subject{ @uploader.large }
    it{ should have_dimensions(300, 150) }
  end

  describe '#x_large' do
    subject{ @uploader.x_large }
    it{ should have_dimensions(600, 300) }
  end
end


