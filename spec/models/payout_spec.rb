require 'spec_helper'

describe Payout do
  before(:all) { PaymentEngine.destroy_all }

  describe 'completion of payout' do
    it 'completes a payout for each payment engine initialized' do
      payout          = double('My Payout')
      payout_instance = double('My Payout instance')
      engine          = double('Payment Engine', payout_class: payout)
      PaymentEngine.new(engine).save
      expect(payout).to          receive(:new).with(1, 3).and_return(payout_instance)
      expect(payout_instance).to receive(:complete)
      Payout.complete(1, 3)
    end
  end
end
