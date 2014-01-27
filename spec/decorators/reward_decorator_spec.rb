require 'spec_helper'

describe RewardDecorator do
  include ActionView::Helpers::NumberHelper

  let(:reward){ create(:reward, description: 'envie um email para foo@bar.com', days_to_delivery: 20, maximum_contributions: 20) }

  describe "#display_description" do
    subject{ reward.display_description }
    it{ should == "<p>envie um email para <a href=\"mailto:foo@bar.com\" target=\"blank\">foo@bar.com</a></p>" }
  end

  describe "#display_minimum" do
    subject{ reward.display_minimum }
    it{ should == number_to_currency(reward.minimum_value, precision: 0) }
  end

  describe '#display_deliver_prevision' do
    subject { reward.display_deliver_prevision }
    it{ should == I18n.l((reward.project.expires_at + reward.days_to_delivery.days), format: :prevision) }
  end

  describe '#display_remaining' do
    subject { reward.display_remaining }
    it{ should == I18n.t('reward.display_remaining', remaining: 20, maximum: 20) }
  end
end
