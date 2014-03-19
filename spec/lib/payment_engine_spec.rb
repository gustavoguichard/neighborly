# encoding: utf-8

require 'spec_helper'

describe PaymentEngine do
  let(:engine){ {name: 'test', review_path: ->(contribution){ "/#{contribution}" }, locale: 'en'} }
  let(:engine_pt){ {name: 'test pt', review_path: ->(contribution){ "/#{contribution}" }, locale: 'pt'} }
  let(:contribution){ FactoryGirl.create(:contribution) }
  before{ PaymentEngine.clear }

  describe ".register" do
    before{ PaymentEngine.register engine }
    subject{ PaymentEngine.engines }
    it{ should == [engine] }
  end

  describe ".clear" do
    before do
      PaymentEngine.register engine
      PaymentEngine.clear
    end
    subject{ PaymentEngine.engines }
    it{ should be_empty }
  end

  describe ".configuration" do
    subject{ PaymentEngine.configuration }
    it{ should == ::Configuration }
  end

  describe ".create_payment_notification" do
    subject{ PaymentEngine.create_payment_notification({ contribution_id: contribution.id, extra_data: { test: true } }) }
    it{ should == PaymentNotification.where(contribution_id: contribution.id).first }
  end

  describe ".find_payment" do
    subject{ PaymentEngine.find_payment({ id: contribution.id }) }
    it{ should == contribution }
  end

  describe ".engines" do
    subject{ PaymentEngine.engines }
    before do
      PaymentEngine.register engine
      PaymentEngine.register engine_pt
    end

    context "when locale is en" do
      it{ should == [engine, engine_pt] }
    end
  end
end
