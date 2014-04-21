require 'spec_helper'

describe ContentImageUploader do
  include CarrierWave::Test::Matchers
  let(:image){ FactoryGirl.create(:image) }

  before do
    HeroImageUploader.enable_processing = true
    @uploader = described_class.new(image, :file)
    @uploader.store!(File.open("#{Rails.root}/spec/fixtures/image.png"))
  end

  after do
    described_class.enable_processing = false
    @uploader.remove!
  end

  describe '#medium' do
    subject{ @uploader.medium }
    it{ should have_dimensions(170, 200) }
  end

end



