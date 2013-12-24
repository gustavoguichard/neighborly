require 'spec_helper'

describe OrganizationUploader do
  include CarrierWave::Test::Matchers
  let(:organization){ FactoryGirl.create(:organization) }

  before do
    OrganizationUploader.enable_processing = true
    @uploader = OrganizationUploader.new(organization, :image)
    @uploader.store!(File.open("#{Rails.root}/spec/fixtures/image.png"))
  end

  after do
    OrganizationUploader.enable_processing = false
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

