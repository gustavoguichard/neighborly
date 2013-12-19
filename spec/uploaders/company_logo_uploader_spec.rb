require 'spec_helper'

describe CompanyLogoUploader do
  include CarrierWave::Test::Matchers
  let(:user){ FactoryGirl.create(:user) }

  before do
    CompanyLogoUploader.enable_processing = true
    @uploader = CompanyLogoUploader.new(user, :company_logo)
    @uploader.store!(File.open("#{Rails.root}/spec/fixtures/image.png"))
  end

  after do
    CompanyLogoUploader.enable_processing = false
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

end
