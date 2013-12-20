require 'spec_helper'

describe HeroImageUploader do
  include CarrierWave::Test::Matchers
  let(:user){ FactoryGirl.create(:user) }

  before do
    HeroImageUploader.enable_processing = true
    @uploader = HeroImageUploader.new(user, :hero_image)
    @uploader.store!(File.open("#{Rails.root}/spec/fixtures/image.png"))
  end

  after do
    HeroImageUploader.enable_processing = false
    @uploader.remove!
  end

  describe '#blur' do
    subject{ @uploader.blur }
    it{ should have_dimensions(170, 200) }
  end

end


