require 'spec_helper'

describe UserUploader do
  include CarrierWave::Test::Matchers
  let(:press_asset){ FactoryGirl.create(:press_asset) }

  before do
    PressUploader.enable_processing = true
    @uploader = PressUploader.new(press_asset, :image)
    @uploader.store!(File.open("#{Rails.root}/spec/fixtures/image.png"))
  end

  after do
    PressUploader.enable_processing = false
    @uploader.remove!
  end

  describe '#thumb' do
    subject{ @uploader.thumb }
    it{ should have_dimensions(170, 60) }
  end

end

