require 'spec_helper'

describe RewardDecorator do
  include ActionView::Helpers::NumberHelper

  let(:reward){ create(:reward, description: 'envie um email para foo@bar.com') }

  describe "#display_description" do
    subject{ reward.display_description }
    it{ should == "<p>envie um email para <a href=\"mailto:foo@bar.com\" target=\"_blank\">foo@bar.com</a></p>" }
  end

  describe "#display_minimum" do
    subject{ reward.display_minimum }
    it{ should == number_to_currency(reward.minimum_value, precision: 0) }
  end

end
