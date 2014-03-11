require 'spec_helper'

describe FlashMessagesHelper do
  describe "flash messages" do
    it "include 'alert' flash in html" do
      flash = ActionDispatch::Flash::FlashHash.new(alert: 'foobar')
      helper.stub(:flash).and_return(flash)
      expect(helper.flash_messages.to_s).to include('foobar')
    end

    it "include 'notice' flash in html" do
      flash = ActionDispatch::Flash::FlashHash.new(notice: 'foobar')
      helper.stub(:flash).and_return(flash)
      expect(helper.flash_messages.to_s).to include('foobar')
    end

    it "exclude non alert/notice flashes" do
      flash = ActionDispatch::Flash::FlashHash.new(param_to_a_page: 'foobar')
      helper.stub(:flash).and_return(flash)
      expect(helper.flash_messages.to_s).to_not include('foobar')
    end

    it "returns blank result when no valid flashes are given" do
      flash = ActionDispatch::Flash::FlashHash.new(param_to_a_page: 'foobar')
      helper.stub(:flash).and_return(flash)
      expect(helper.flash_messages.to_s).to be_blank
    end
  end
end
