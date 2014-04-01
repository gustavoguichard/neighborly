require 'spec_helper'

describe PaymentEngine do
  let(:creditcard)   { double('Balanced::Creditcard',  name: 'creditcard') }
  let(:bankaccount)  { double('Balanced::Bankaccount', name: 'bankaccount') }
  let(:contribution) { FactoryGirl.create(:contribution) }

  before { PaymentEngine.destroy_all }

  describe '.save' do
    it 'should save the engine' do
      PaymentEngine.new(creditcard).save
      expect(PaymentEngine.all).to eq [creditcard]
    end
  end

  describe '.destroy_all' do
    before { PaymentEngine.new(creditcard).save  }

    it 'should destroy all engines' do
      PaymentEngine.destroy_all
      expect(PaymentEngine.all).to be_empty
    end
  end

  describe '.configuration' do
    it 'should turn configuration class' do
      expect(PaymentEngine.configuration).to eq ::Configuration
    end
  end

  describe '.create_payment_notification' do
    subject do
      PaymentEngine.create_payment_notification({ contribution_id: contribution.id,
                                                  extra_data: { test: true } })
    end

    it 'should create payment notification' do
      should == PaymentNotification.where(contribution_id: contribution.id).first
    end
  end

  describe '.find_payment' do
    subject { PaymentEngine.find_payment({ id: contribution.id }) }

    it 'should return the correct contribution' do
      should == contribution
    end
  end

  describe '.all' do
    before do
      PaymentEngine.new(creditcard).save
      PaymentEngine.new(bankaccount).save
    end

    it 'should return all engines' do
      expect(PaymentEngine.all).to eq [creditcard, bankaccount]
    end
  end

  after(:all) do
    PaymentEngine.destroy_all
  end
end
