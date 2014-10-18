require 'spec_helper'

describe UserDecorator do
  describe "#display_name" do
    subject { user.display_name }

    context 'when profile_type is personal' do
      context "when we have only a name" do
        let(:user) { create(:user, name: nil, name: 'name') }
        it { should == 'name' }
      end

      context "when we have no name" do
        let(:user) { create(:user, name: nil, nickname: nil) }
        it { should == user.email }
      end
    end

    context 'when profile_type is organization' do
      context "when we the organization name" do
        let(:user){ create(:user, profile_type: 'organization', organization_attributes: { name: 'Neighbor.ly' }) }
        it { should == 'Neighbor.ly' }
      end

      context "when we have no organization name" do
        let(:user){ create(:user, profile_type: 'organization', organization_attributes: { name: nil }) }
        it { should == user.email }
      end
    end
  end

  describe "#display_image_html" do
    let(:user){ build(:user, name: 'Sherlock', image_url: 'http://image.jpg', uploaded_image: nil )}
    let(:options){ {width: 300, height: 300} }
    subject{ user.display_image_html(options) }
    it { should == "<figure class=\"profile-image personal\"><img alt=\"Sherlock\" class=\"avatar\" src=\"http://image.jpg\" style=\"width: #{options[:width]}px; height: #{options[:height]}px\" /></figure>"}
  end

  describe "#display_image" do
    subject{ user.display_image }

    context 'when profile_type is personal' do
      context "when we have an uploaded image" do
        let(:user){ build(:user, uploaded_image: 'image.png' )}
        before do
          image = double(url: 'image.png')
          image.stub(:thumb_avatar).and_return(image)
          user.stub(:uploaded_image).and_return(image)
        end
        it{ should == 'image.png' }
      end

      context "when we have an image url" do
        let(:user){ build(:user, image_url: 'image.png') }
        it{ should == 'image.png' }
      end
    end

    context 'when profile_type is organization' do
      context "when we have a organization image" do
        let(:user){ build(:user, profile_type: 'organization', organization_attributes: { image: 'image.png'} )}
        before do
          image = double(url: 'image.png')
          image.stub(:thumb).and_return(image)
          image.stub(:large).and_return(image)
          user.organization.stub(:image).and_return(image)
        end
        it{ should == 'image.png' }
      end

      context 'when we dont have a organization image' do
        let(:user){ build(:user, profile_type: 'organization', organization_attributes: { image: nil }) }
        it{ should == '/assets/logo-blank.jpg' }
      end
    end
  end

  describe "#short_name" do
    subject { create(:user, name: 'My Name Is Lorem Ipsum Dolor Sit Amet') }
    its(:short_name) { should == 'My Name Is Lorem ...' }
  end

  describe "#medium_name" do
    subject { create(:user, name: 'My Name Is Lorem Ipsum Dolor Sit Amet And This Is a Bit Name I Think') }
    its(:medium_name) { should == 'My Name Is Lorem Ipsum Dolor Sit Amet A...' }
  end

  describe "#display_total_of_contributions" do
    subject { create(:user) }
    context "with confirmed contributions" do
      before do
        create(:contribution, state: 'confirmed', user: subject, value: 500.0)
      end
      its(:display_total_of_contributions) { should == '$500.00'}
    end
  end
end
