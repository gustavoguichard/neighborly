require 'spec_helper'

describe TagDecorator do
  describe "#display_name" do
    subject{ tag.display_name }
    let(:tag){ Tag.create name: 'test with rspec' }
    it{ should == 'Test With Rspec' }
  end
end
