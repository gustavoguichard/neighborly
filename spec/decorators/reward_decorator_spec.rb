require 'spec_helper'

describe RewardDecorator do
  include ActionView::Helpers::NumberHelper

  let(:reward){ create(:reward, maximum_contributions: 20) }

  describe '#display_remaining' do
    subject { reward.display_remaining }
    it{ should == I18n.t('reward.display_remaining', remaining: 20, maximum: 20) }
  end
end
