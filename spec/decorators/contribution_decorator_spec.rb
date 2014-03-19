require 'spec_helper'

describe ContributionDecorator do
  let(:contribution) { Contribution.new }
  subject { described_class.new(contribution) }

  describe "#display_confirmed_at" do
    subject{ contribution.display_confirmed_at }
    context "when confirmet_at is not nil" do
      let(:contribution){ build(:contribution, confirmed_at: Time.now) }
      it{ should == I18n.l(contribution.confirmed_at.to_date) }
    end

    context "when confirmet_at is nil" do
      let(:contribution){ build(:contribution, confirmed_at: nil) }
      it{ should be_nil }
    end
  end

  describe 'display value' do
    before do
      contribution.value               = 9
      contribution.payment_service_fee = 1
    end

    context 'when project paid the fees' do
      before do
        contribution.payment_service_fee_paid_by_user = false
      end

      it 'returns value as currency' do
        displayed_value = '$9.00'
        subject.stub(:number_to_currency).with(9).and_return(displayed_value)
        expect(subject.display_value).to eql(displayed_value)
      end
    end

    context 'when user paid the fees' do
      before do
        contribution.payment_service_fee_paid_by_user = true
      end

      it 'sums payment service fee with contribution\'s value' do
        displayed_value = '$10.00'
        subject.stub(:number_to_currency).with(10).and_return(displayed_value)
        expect(subject.display_value).to eql(displayed_value)
      end
    end
  end
end

